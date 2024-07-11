extends Node3D

@export_range(0,5,.1) var dolly_speed : float = 4.0
@export_range(0,0.1,.01) var rotation_speed : float = .02
@export_range(-180,180,5) var starting_rotation = 15
@export_range(0,90,1) var min_elevation : int = 10
@export_range(0,90,1) var max_elevation : int = 45
@export_range(0,90,1) var start_elevation : int = 15
@export_range(0,50,1) var zoom_speed : int = 20
@export_range(0,100,1) var min_zoom : int = 2
@export_range(0,100,1) var max_zoom : int = 10
@export_range(0,20,1) var start_zoom : int = 4
@export var show_target : bool = true

@onready var dolly : Node3D = $Dolly
@onready var horizontal_pivot = $Dolly/HorizontalPivot
@onready var vertical_pivot = $Dolly/HorizontalPivot/VerticalPivot
@onready var cam = $Dolly/HorizontalPivot/VerticalPivot/Camera3D
@onready var target = $Dolly/target

var freemove : bool = false
var curr_pivot : float = 0
var key_controls : Dictionary = {
	"camera_foreward": [KEY_W],
	"camera_back": [KEY_S],
	"camera_left": [KEY_A],
	"camera_right": [KEY_D]
}
var mouse_controls : Dictionary = {
	"activate_zoom" : [MOUSE_BUTTON_MIDDLE],
	"zoom_in" : [MOUSE_BUTTON_WHEEL_UP],
	"zoom_out" : [MOUSE_BUTTON_WHEEL_DOWN]
}


func _ready() -> void :
	target.visible = show_target
	vertical_pivot.rotation.x = deg_to_rad(-start_elevation)
	horizontal_pivot.rotation.y = deg_to_rad(starting_rotation)
	cam.translate_object_local(Vector3.BACK * start_zoom)
	mapinputs()
	
func _process(delta) -> void :
	horizontalmove(delta)
	
	if Input.is_action_just_pressed("activate_zoom"):
		freemove = true
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if Input.is_action_just_released("activate_zoom"):
		freemove = false
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if freemove :
		horizontalswing(delta)
		verticalswing(delta)
	
	zoom(delta)
	
func mapinputs() -> void :
	var ev
	for action in key_controls :
		if InputMap.has_action(action):
			printerr(action + " already mapped")
		else :
			InputMap.add_action(action)
			print(action)
		for key in key_controls[action]:
			ev = InputEventKey.new()
			ev.keycode = key
			InputMap.action_add_event(action, ev)
			
	for action in mouse_controls :
		if InputMap.has_action(action):
			printerr(action + " already mapped")
		else :
			InputMap.add_action(action)
			print(action)
		for key in mouse_controls[action]:
			ev = InputEventMouseButton.new()
			ev.button_index = key
			InputMap.action_add_event(action, ev)
	

func horizontalmove(delta) -> void :
	var direction := Input.get_vector("camera_left","camera_right","camera_foreward","camera_back")
	var direction3d := Vector3(direction.x,0,direction.y)
	dolly.position += direction3d	* delta * dolly_speed
	
func horizontalswing(delta) -> void:
	var pivotby : float = Input.get_last_mouse_velocity().x * delta * rotation_speed
	horizontal_pivot.rotation.y = horizontal_pivot.rotation.y + pivotby
	#var pivotby = horizontal_pivot.rotation.y + (Input.get_last_mouse_velocity().x * delta * rotation_speed)
	#horizontal_pivot.rotate.y = clamp(pivotby, deg_to_rad(min_elevation), deg_to_rad(max_elevation))
	
func verticalswing(delta)-> void:
	var pivotby : float = Input.get_last_mouse_velocity().y * delta * rotation_speed
	curr_pivot -= pivotby
	vertical_pivot.rotation.x = clamp(vertical_pivot.rotation.x-pivotby, deg_to_rad(-max_elevation), deg_to_rad(-min_elevation))

func zoom(delta) -> void:	
	
	var distance : float = cam.global_position.distance_to(target.global_position)
	
	if Input.is_action_just_released("zoom_in") and distance > min_zoom:
		cam.translate_object_local(Vector3.FORWARD * zoom_speed * delta)
	
	if Input.is_action_just_released("zoom_out") and distance < max_zoom:
		cam.translate_object_local(Vector3.BACK * zoom_speed * delta)


