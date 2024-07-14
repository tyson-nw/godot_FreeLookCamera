extends Node3D

@export_range(0,5,.1) var dolly_speed : float = 4.0
@export_range(0,0.1,.01) var rotation_speed : float = .02
@export_range(-180,180,5) var starting_rotation : int = 15
@export_range(-180,180,5) var min_rotation : int = -180
@export_range(-180,180,5) var max_rotation : int = 180
@export_range(0,90,1) var min_elevation : int = 10
@export_range(0,90,1) var max_elevation : int = 45
@export_range(0,90,1) var start_elevation : int = 15
@export_range(0,50,1) var zoom_speed : int = 20
@export_range(0,100,1) var min_zoom : int = 2
@export_range(0,100,1) var max_zoom : int = 10
@export_range(0,20,1) var start_zoom : int = 4
@export var freeze_zoom : bool = false
@export var show_target : bool = false
@export var lock_dolly : bool = false

@onready var dolly : Node3D = $Dolly
@onready var horizontal_pivot = $Dolly/HorizontalPivot
@onready var vertical_pivot = $Dolly/HorizontalPivot/VerticalPivot
@onready var camera = $Dolly/HorizontalPivot/VerticalPivot/MainCamera
@onready var target = $Dolly/target

var freemove : bool = false
var curr_pivot : float = 0
var key_controls : Dictionary = {
	"flc_camera_foreward": [KEY_W],
	"flc_camera_back": [KEY_S],
	"flc_camera_left": [KEY_A],
	"flc_camera_right": [KEY_D]
}
var mouse_controls : Dictionary = {
	"flc_activate_zoom" : [MOUSE_BUTTON_MIDDLE],
	"flc_zoom_in" : [MOUSE_BUTTON_WHEEL_UP],
	"flc_zoom_out" : [MOUSE_BUTTON_WHEEL_DOWN]
}



func _ready() -> void :
	target.visible = show_target
	vertical_pivot.rotation.x = deg_to_rad(-start_elevation)
	
	if lock_dolly :
		horizontal_pivot.rotation.y = deg_to_rad(starting_rotation)
	else:
		dolly.rotation.y = deg_to_rad(starting_rotation)
		
	camera.translate_object_local(Vector3.BACK * start_zoom)
	mapinputs()
	
	
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
	
	if Input.is_action_just_pressed("flc_activate_zoom"):
		freemove = true
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if Input.is_action_just_released("flc_activate_zoom"):
		freemove = false
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if freemove :
		horizontalswing(delta)
		verticalswing(delta)
	
	zoom(delta)

# controls the movement of the dolly
func horizontalmove(delta) -> void :
	var direction := Input.get_vector("flc_camera_left","flc_camera_right","flc_camera_foreward","flc_camera_back")
	var direction3d := Vector3(direction.x, 0, direction.y)
		
	if lock_dolly :
		dolly.position += direction3d * delta * dolly_speed
	else:
		dolly.translate_object_local(direction3d * zoom_speed * delta)
		# get direction currently pointing
		# get direction of input
		
		# move relative to currently pointing direction.
		pass
		
# controls horizontal swing
func horizontalswing(delta) -> void:
	var pivotby : float = Input.get_last_mouse_velocity().x * delta * rotation_speed
	if lock_dolly :
		if horizontal_pivot.rotation.y + pivotby > deg_to_rad(min_rotation) and horizontal_pivot.rotation.y + pivotby < deg_to_rad(max_rotation) :
			horizontal_pivot.rotation.y = horizontal_pivot.rotation.y + pivotby
	else:
		if dolly.rotation.y + pivotby > deg_to_rad(min_rotation) and dolly.rotation.y + pivotby < deg_to_rad(max_rotation) :
			dolly.rotation.y = dolly.rotation.y + pivotby

	
func verticalswing(delta)-> void:
	var pivotby : float = Input.get_last_mouse_velocity().y * delta * rotation_speed
	curr_pivot -= pivotby
	vertical_pivot.rotation.x = clamp(vertical_pivot.rotation.x-pivotby, deg_to_rad(-max_elevation), deg_to_rad(-min_elevation))

func zoom(delta) -> void:	
	
	var distance : float = camera.global_position.distance_to(target.global_position)
	
	if freeze_zoom or $Dolly/HorizontalPivot/VerticalPivot/MainCamera.freeze_zoom :
		return
	
	if Input.is_action_just_released("flc_zoom_in") and distance > min_zoom:
		camera.translate_object_local(Vector3.FORWARD * zoom_speed * delta)
	
	if Input.is_action_just_released("flc_zoom_out") and distance < max_zoom:
		camera.translate_object_local(Vector3.BACK * zoom_speed * delta)


