extends Node3D

@onready var animation_player: AnimationPlayer = $thunderV2/AnimationPlayer

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	queue_free()
