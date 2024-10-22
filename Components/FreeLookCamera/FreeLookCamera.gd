extends CharacterBody3D
@export var show_target : bool = false
@export_group("Dolly Position")
@export var start_position : Vector3 = Vector3(0,0,0)
@export_range(0,5,.1) var dolly_speed : float = 4.0

@export_group("Mouse Rotation")
@export_range(-180,180,5) var starting_rotation : int = 0
@export_range(0,0.1,.01) var rotation_speed : float = .02

@export_subgroup("Rotation Limits")
@export var limit_rotation : bool = true
@export_range(-180,180,5) var min_rotation : int = -180
@export_range(-180,180,5) var max_rotation : int = 180

@export_group("Keyboard Rotation")
@export var rotatate_on_keypress_hold : bool = true

@export_subgroup("Rotate on hold")
@export_range(0,360,1) var rotate_on_keypress_speed : float = 5
@export_subgroup("Rotate on tap")
@export_range(0,360,1) var rotate_on_keypress : int = 5
@export_range(0,5,0.01) var rotate_on_keypress_time : float = 1.0

@export_group("Elevation")
@export_range(0,90,1) var min_elevation : int = 10
@export_range(0,90,1) var max_elevation : int = 45
@export_range(0,90,1) var start_elevation : int = 15

@export_group("Zoom")
@export var freeze_zoom : bool = false
@export_range(0,20,1) var start_zoom : int = 4
@export_range(0,1,.5) var zoom_speed : float = 1
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
@onready var vertical_pivot : SpringArm3D = $Dolly/VerticalPivot
@onready var camera : Camera3D = $Dolly/VerticalPivot/MainCamera

var last_camera_location : Vector3

var _unlock_swing : bool = false
var _curr_pivot : float = 0
var _swinging : String = ""
var _swing_from : float = 0
var _swing_to : float = 0
var _swung : float = 0

func _ready() -> void :
	dolly.visible = show_target

	vertical_pivot.rotation.x = deg_to_rad(-start_elevation)
	vertical_pivot.spring_length = start_zoom
	$".".position = start_position
	dolly.rotation.y = deg_to_rad(starting_rotation)
		
	camera.translate_object_local(Vector3.BACK * start_zoom)
	mapinputs()
	
	last_camera_location = camera.position
	
	vertical_pivot.collision_mask = ($".".collision_mask)
	
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
	
	zoom()
	mouse_swing(delta)
	keypress_swing(delta)
	horizontal_move()

# controls the movement of the dolly
func horizontal_move() -> void :
	var direction := Input.get_vector("flc_camera_left","flc_camera_right","flc_camera_foreward","flc_camera_back")
	var direction3d := Vector3(direction.x, 0, direction.y)
	direction3d = direction3d.rotated(Vector3.UP, dolly.rotation.y)
	if direction:
		velocity.x = direction3d.x * dolly_speed
		velocity.z = direction3d.z * dolly_speed
	else:
		velocity.x = move_toward(velocity.x, 0, dolly_speed)
		velocity.z = move_toward(velocity.z, 0, dolly_speed)
	
	move_and_slide()
	
	last_camera_location = camera.position

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
	last_camera_location = camera.position

func keypress_swing(delta : float) -> void :
	if rotatate_on_keypress_hold :
		#Rotate when holdign down the key
		if Input.is_action_pressed("flc_camera_swing_left"):
			horizontalswing(-1 * rotate_on_keypress_speed * delta)
			pass
		if Input.is_action_pressed("flc_camera_swing_right") :
			horizontalswing(rotate_on_keypress_speed * delta)
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
	last_camera_location = camera.position

# controls horizontal swing
func horizontalswing(pivotby : float) -> void:
	if limit_rotation :
		if dolly.rotation.y + pivotby > deg_to_rad(min_rotation) and dolly.rotation.y + pivotby < deg_to_rad(max_rotation) :
			dolly.rotation.y = dolly.rotation.y + pivotby
	else:
		dolly.rotation.y = dolly.rotation.y + pivotby
	last_camera_location = camera.position

func verticalswing(delta)-> void:
	var pivotby : float = Input.get_last_mouse_velocity().y * delta * rotation_speed
	_curr_pivot -= pivotby
	vertical_pivot.rotation.x = clamp(vertical_pivot.rotation.x-pivotby, deg_to_rad(-max_elevation), deg_to_rad(-min_elevation))
	last_camera_location = camera.position
	
func zoom() -> void:	
	
	#var distance : float = camera.global_position.distance_to(target.global_position)
	var distance : float = vertical_pivot.spring_length
	
	if freeze_zoom or camera.freeze_zoom :
		return
	
	if Input.is_action_just_pressed("flc_zoom_in") and distance > min_zoom:
		vertical_pivot.spring_length -= zoom_speed
		

	if Input.is_action_just_pressed("flc_zoom_out") and distance < max_zoom:
		vertical_pivot.spring_length += zoom_speed
		

	last_camera_location = camera.position

