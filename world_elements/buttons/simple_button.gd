extends Node3D

@onready var button = $button
@onready var player = get_tree().get_first_node_in_group("player") as CharacterBody3D
@onready var blocks = get_tree().get_first_node_in_group("moving_blocks") as RigidBody3D
@export var is_a_block_button : bool = false
@warning_ignore("unused_signal")
signal trigger_effect


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body == player:
		if not is_a_block_button:
			var tween = create_tween()
			tween.tween_property(button, "position", Vector3(0, -0.047, 0), 1.5)
			emit_signal("trigger_effect")
	if body == blocks:
		if is_a_block_button:
			var tween = create_tween()
			tween.tween_property(button, "position", Vector3(0, -0.047, 0), 1.5)
			emit_signal("trigger_effect")


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body == player:
		var tween = create_tween()
		tween.tween_property(button, "position", Vector3(0, 0.152, 0), 3)
