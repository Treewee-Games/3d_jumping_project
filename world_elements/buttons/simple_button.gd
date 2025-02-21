extends Node3D

@onready var button = $button
@onready var player = get_tree().get_first_node_in_group("player") as CharacterBody3D
@onready var area = $Area3D

signal trigger_effect
signal exit_effect

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body == player:
		var tween = create_tween()
		tween.tween_property(button, "position", Vector3(0, -0.047, 0), 1.5)
		emit_signal("trigger_effect")


func _on_area_3d_body_exited(_body: Node3D) -> void:
	var tween = create_tween()
	tween.tween_property(button, "position", Vector3(0, 0.152, 0), 3)
	emit_signal("exit_effect")
