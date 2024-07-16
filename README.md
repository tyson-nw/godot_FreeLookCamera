# godot_FreeLookCamera

This is a simple freelook camera that pivots around a central point. That point han be moved horizonally in every direction The camera can vertically and horizontally pivot around it the point. And it can zoom in and out. It has stops so you can limit the vertical angle and the hof far you can zoom in and out

<div style="text-align:center">

[![Demo video](https://i9.ytimg.com/vi_webp/Z7Rgp6_L-KE/mqdefault.webp?v=6690b98a&sqp=CPzywrQG&rs=AOn4CLA0QeUdw8Cde62IWYWuJO4Zw-f1Xw)](https://youtu.be/Z7Rgp6_L-KE)

</div>

## Installation

1. Copy the `free_look_camera.tscn` to your `res://Scenes` folder 
2. `FreeLookCamera.gd` and `MainCamera.gd` to your `res://Scripts` folder.
3. Drag the `free_look_camera.tscn` into your scene.

## Config

| key | type | description |
|:--: |:--:|:--|
|dolly_speed | float | Multipler that adjusts the target's motion horizontally. |
|rotation_speed| float | Multiplyer that amplifies the imput to control pivoiding horizontally around the point. |
|starting_rotation | int in degrees | Starting camera offest from the baseline in degrees. |
| limit_rotation | bool | Whether to limit or allow full rotation of the camera
|min_rotation | int in degrees | How far left the camera can rotate around the target point.|
|max_rotation | int in degrees | How far right the camera can rotate aroung the target point |
|min_elevation| int in degrees | How low the camera can get in degrees. | 
|min_elevation| int in degrees | How high the camera can get in degrees. | 
|start_elevation| int in degrees | Starting camera angle in degrees. |
|zoom_speed| int | Multiplier that adjusts how fast a camera zooms in and out. |
|min_zoom| int | How close the camera can get to the target point. |
|max_zoom | int | How far the camera can get away from the target point. |
|start_zoom | int | Starting distance from the target point .|
|freeze_zoom | bool | disable zoom if you are using the mousewheel elsewhere. IF you can't reference the FreeLookCamera node, you can set get_viewport().get_camera_3d().freeze_zoom to true and it will also lock the zoom. |
|show_target | bool | Shows the target indicator sphere. |
|lock_dolly | bool | Locks the dolly so the wasd movement is independant of where the camera is looking. |
|key_controls| Dictionary | the keys that trigger target point movement. Keys must be in an array associated with each key. |
|mouse_controls| Dictionary | the mouse actions that trigger camera movement. Keys must be in an array associated with each key. |

## Controls

| input | input key | description |
|:--:|:--:|:--|
|flc_camera_foreward| KEY_W |
|flc_camera_back | KEY_S|
|flc_camera_left | KEY_A|
|flc_camera_right | KEY_D|
|flc_activate_zoom| MOUSE_BUTTON_MIDDLE |
|flc_zoom_in|MOUSE_BUTTON_WHEEL_UP|
|flc_zoom_out|MOUSE_BUTTON_WHEEL_DOWN|

## ToDo
- Add joystic support
- add camera collision to dynamically adjust zoom
- add keyboard zoom
- add keyboard pan amd pitch
