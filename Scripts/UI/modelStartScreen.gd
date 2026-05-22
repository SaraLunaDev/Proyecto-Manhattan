extends Node3D

@export var skeleton: Skeleton3D
var horizontal_limit := 45.0
var vertical_limit := 20.0
var smooth_speed := 5.0
var neck_rotation : Quaternion
var horizontal := 0.0
var vertical := 0.0
var viewport_size: Vector2
var mouse_pos: Vector2

func _ready():
	var neck_bone = skeleton.find_bone("Head")
	neck_rotation = skeleton.get_bone_pose_rotation(neck_bone)

func _process(delta):
	viewport_size = get_viewport().get_visible_rect().size
	mouse_pos = get_viewport().get_mouse_position()
	
	var x = (mouse_pos.x / viewport_size.x - 0.5) * 2.0
	var y = (mouse_pos.y / viewport_size.y - 0.5) * 2.0
	
	horizontal = lerp(horizontal, deg_to_rad(horizontal_limit) * x, smooth_speed * delta)
	vertical = lerp(vertical, deg_to_rad(vertical_limit) * y, smooth_speed * delta)
	
	var new_rotation = neck_rotation * Quaternion.from_euler(Vector3(vertical, horizontal, 0.0))
	skeleton.set_bone_pose_rotation(1, new_rotation)
