extends Node3D
@export var show_target : bool = false
@export_group("Dolly Position")
@export var start_position : Vector3 = Vector3(0,0,0)
@export_range(0,5,.1) var dolly_speed : float = 4.0

@export_group("Rotation")
@export_range(-180,180,5) var starting_rotation : int = 0
@export_range(0,0.1,.01) var rotation_speed : float = .02

@export_subgroup("Rotation Limits")
@export var limit_rotation : bool = true
@export_range(-180,180,5) var min_rotation : int = -180
@export_range(-180,180,5) var max_rotation : int = 180

@export_subgroup("Rotation Keys")
@export var rotatate_on_keypress_hold : bool = true
@export_range(0,360,1) var rotate_on_keypress : float = 5
@export_range(0,5,0.01) var rotate_on_keypress_time : float = 1.0

@export_group("Elevation")
@export_range(0,90,1) var min_elevation : int = 10
@export_range(0,90,1) var max_elevation : int = 45
@export_range(0,90,1) var start_elevation : int = 15

@export_group("Zoom")
@export var freeze_zoom : bool = false
@export_range(0,20,1) var start_zoom : int = 4
@export_range(0,50,1) var zoom_speed : int = 20
@export_range(0,100,1) var min_zoom : int = 2
@export_range(0,100,1) var max_zoom : int = 10

@export_group("Controls")
@export var key_controls : Dictionary = {
	"flc_camera_foreward": [KEY_W],
	"flc_camera_back": [KEY_S],
	"flc_camera_left": [KEY_A],
	"flc_camera_right": [KEY_D],
	"flc_camera_swing_left" : [KEY_Q],
	"flc_camera_swing_right": [KEY_E]
}
@export var mouse_controls : Dictionary = {
	"flc_activate_swing" : [MOUSE_BUTTON_MIDDLE],
	"flc_zoom_in" : [MOUSE_BUTTON_WHEEL_UP],
	"flc_zoom_out" : [MOUSE_BUTTON_WHEEL_DOWN]
}



@onready var dolly : Node3D = $Dolly
@onready var horizontal_pivot = $Dolly/HorizontalPivot
@onready var vertical_pivot = $Dolly/HorizontalPivot/VerticalPivot
@onready var camera = $Dolly/HorizontalPivot/VerticalPivot/MainCamera
@onready var target = $Dolly/target

var last_camera_location : Vector3

var _unlock_swing : bool = false
var _curr_pivot : float = 0
var _swinging : String = ""
var _swing_from : float = 0
var _swing_to : float = 0
var _swing_step : float = 0
var _swung : float = 0
#var _curr_swing : float = 0


func _ready() -> void :
	target.visible = show_target
	vertical_pivot.rotation.x = deg_to_rad(-start_elevation)
	$".".position = start_position
	dolly.rotation.y = deg_to_rad(starting_rotation)
		
	camera.translate_object_local(Vector3.BACK * start_zoom)
	mapinputs()
	
	last_camera_location = camera.position
	
func mapinputs() -> void :
	var ev
	for action in key_controls :
		if InputMap.has_action(action):
			printerr(action + " already mapped")
		else :
			InputMap.add_action(action)
		for key in key_controls[action]:
			ev = InputEventKey.new()
			ev.keycode = key
			InputMap.action_add_event(action, ev)
			
	for action in mouse_controls :
		if InputMap.has_action(action):
			printerr(action + " already mapped")
		else :
			InputMap.add_action(action)
		for key in mouse_controls[action]:
			ev = InputEventMouseButton.new()
			ev.button_index = key
			InputMap.action_add_event(action, ev)

func _process(delta) -> void :
	horizontalmove(delta)
	zoom(delta)
	mouse_swing(delta)
	keypress_swing(delta)
	
	
	last_camera_location = camera.position

# controls the movement of the dolly
func horizontalmove(delta : float) -> void :
	var direction := Input.get_vector("flc_camera_left","flc_camera_right","flc_camera_foreward","flc_camera_back")
	var direction3d := Vector3(direction.x, 0, direction.y)
		

	dolly.translate_object_local(direction3d * zoom_speed * delta)

func mouse_swing(delta : float) -> void :
	if Input.is_action_just_pressed("flc_activate_swing"):
		_unlock_swing = true
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if Input.is_action_just_released("flc_activate_swing"):
		_unlock_swing = false
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if _unlock_swing :
		horizontalswing(Input.get_last_mouse_velocity().x * delta * rotation_speed)
		verticalswing(delta)
	

func keypress_swing(delta : float) -> void :
	if rotatate_on_keypress_hold :
		#Rotate when holdign down the key
		if Input.is_action_pressed("flc_camera_swing_left"):
			horizontalswing(-1 * rotate_on_keypress * delta)
			pass
		if Input.is_action_pressed("flc_camera_swing_right") :
			horizontalswing(rotate_on_keypress * delta)
	else :
		#Rotate on press, lock acceptance, kick of swing
		if _swinging == "" :

			if Input.is_action_just_pressed("flc_camera_swing_left"):
				_swing_from = dolly.rotation.y
				_swing_to = deg_to_rad(rotate_on_keypress)
				_swinging = "left"
				_swung = 0

			if Input.is_action_just_pressed("flc_camera_swing_right"):
				_swing_from = dolly.rotation.y
				_swing_to = deg_to_rad(rotate_on_keypress)
				_swinging = "right"
				_swung = 0

		if _swinging == "left":
			var step : float =(deg_to_rad(rotate_on_keypress) / rotate_on_keypress_time) * delta
			if(_swung < _swing_to) :
				dolly.rotation.y -= step
				_swung += step
			else:
				dolly.rotation.y = deg_to_rad(round(rad_to_deg(_swing_from-_swing_to)))
				_swinging = ""
				
		if _swinging == "right":
			var step : float =(deg_to_rad(rotate_on_keypress) / rotate_on_keypress_time) * delta
			if(_swung < _swing_to) :
				dolly.rotation.y += step
				_swung += step
			else:
				dolly.rotation.y = deg_to_rad(round(rad_to_deg(_swing_from+_swing_to)))
				_swinging = ""


# controls horizontal swing
func horizontalswing(pivotby : float) -> void:
	if limit_rotation :
		if dolly.rotation.y + pivotby > deg_to_rad(min_rotation) and dolly.rotation.y + pivotby < deg_to_rad(max_rotation) :
			dolly.rotation.y = dolly.rotation.y + pivotby
	else:
		dolly.rotation.y = dolly.rotation.y + pivotby
	
func verticalswing(delta)-> void:
	var pivotby : float = Input.get_last_mouse_velocity().y * delta * rotation_speed
	_curr_pivot -= pivotby
	vertical_pivot.rotation.x = clamp(vertical_pivot.rotation.x-pivotby, deg_to_rad(-max_elevation), deg_to_rad(-min_elevation))

func zoom(delta) -> void:	
	
	var distance : float = camera.global_position.distance_to(target.global_position)
	
	if freeze_zoom or $Dolly/HorizontalPivot/VerticalPivot/MainCamera.freeze_zoom :
		return
	
	if Input.is_action_just_pressed("flc_zoom_in") and distance > min_zoom:
		camera.translate_object_local(Vector3.FORWARD * zoom_speed * delta)
	
	if Input.is_action_just_pressed("flc_zoom_out") and distance < max_zoom:
		camera.translate_object_local(Vector3.BACK * zoom_speed * delta)


