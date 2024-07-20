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

### Dolly Position
| key | type | description |
|:--: |:--:|:--|
|start_position | Vector3 | The position of the target point |
|dolly_speed | float | Multipler that adjusts the target's motion horizontally. |

### Rotation
| key | type | description |
|:--: |:--:|:--|
|starting_rotation | int in degrees | Starting camera offest from the baseline in degrees. |
|rotation_speed| float | Multiplyer that amplifies the imput to control pivoiding horizontally around the point. |

#### Rotation Limits
| key | type | description |
|:--: |:--:|:--|
| limit_rotation | bool | Whether to limit or allow full rotation of the camera
|min_rotation | int in degrees | How far left the camera can rotate around the target point.|
|max_rotation | int in degrees | How far right the camera can rotate aroung the target point |

### Keyboard Rotation
| key | type | description |
|:--: |:--:|:--|
| rotate_on_keypress_hold | bool | Does holding a keypress rotate until you let go, or does pressing a key jump a specific rotation |

#### Rotate on hold
| key | type | description |
|:--: |:--:|:--|
| rotate_on_keypress_speed | float | How fast does the camera rotate when holding|

#### Rotate on tap
| key | type | description |
|:--: |:--:|:--|
| rotate_on_keypress | int | Degrees which the camera should move on keypress |
| rotate_on_keypress_time | float | how many seconds should the camera take to reach the `rotate_on_keypress` angle |

### Elevation
| key | type | description |
|:--: |:--:|:--|
|start_elevation| int in degrees | Starting camera angle in degrees. |
|min_elevation| int in degrees | How low the camera can get in degrees. | 
|min_elevation| int in degrees | How high the camera can get in degrees. |

### Zoom

| key | type | description |
|:--: |:--:|:--|
|zoom_speed| int | Multiplier that adjusts how fast a camera zooms in and out. |
|min_zoom| int | How close the camera can get to the target point. |
|max_zoom | int | How far the camera can get away from the target point. |
|start_zoom | int | Starting distance from the target point .|
|freeze_zoom | bool | disable zoom if you are using the mousewheel elsewhere. IF you can't reference the FreeLookCamera node, you can set get_viewport().get_camera_3d().freeze_zoom to true and it will also lock the zoom. |
|show_target | bool | Shows the target indicator sphere. |

### Controls
Unset any of these to disable the control.
| key | type | description |
|:--: |:--:|:--|
|key_controls| Dictionary | the keys that trigger target point movement. Keys must be in an array associated with each key. |
|mouse_controls| Dictionary | the mouse actions that trigger camera movement. Keys must be in an array associated with each key. |

#### Key Controls

| input | input key | description |
|:--:|:--:|:--|
|flc_camera_foreward| KEY_W | 
|flc_camera_back | KEY_S|
|flc_camera_left | KEY_A|
|flc_camera_right | KEY_D|
|flc_camera_swing_left| KEY_Q |
|flc_camera_swing_right | KEY_E |

#### Mouse Controls
| input | input key | description |
|:--:|:--:|:--|
|flc_activate_swing| MOUSE_BUTTON_MIDDLE |
|flc_zoom_in|MOUSE_BUTTON_WHEEL_UP|
|flc_zoom_out|MOUSE_BUTTON_WHEEL_DOWN|

## ToDo
- Add joystic support
- add camera collision to dynamically adjust zoom
- add keyboard zoom
- add swip controls
