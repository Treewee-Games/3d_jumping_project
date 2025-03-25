extends "res://world_elements/platforms/platform.gd"

@export var falling_time : float
@export var falling_distance: float
@export var player_entered: bool = false

func _on_falling_trigger_body_entered(body: Node3D) -> void:
	if body == player:
		player_entered = true
		if not platform_up or player_entered:
			await get_tree().create_timer(falling_time).timeout
			platform_up = true
			var target_position = platform.global_position + Vector3(move_distance_x, move_distance_y + falling_distance, move_distance_z) #Move Up
			var tween = create_tween()
			tween.tween_property(platform, "global_position", target_position , move_time).set_ease(Tween.EASE_IN_OUT)
			platform.constant_linear_velocity = Vector3(move_distance_x, move_distance_y, move_distance_z)/move_time
			await tween.finished
			platform.constant_linear_velocity = Vector3.ZERO
			await get_tree().create_timer(timing).timeout
			respawn_falling_platform()

func respawn_falling_platform()->void:
	platform.global_transform.origin = origin.global_transform.origin
	platform_up = false
	player_entered = false
