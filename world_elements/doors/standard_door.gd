extends Node3D

@onready var door = $StaticBody3D
@onready var player = get_tree().get_first_node_in_group("player") as CharacterBody3D


func _on_door_trigger_body_exited(_body: Node3D) -> void:
	var tween = create_tween()
	tween.tween_property(door, "position", Vector3(0, 0, 0), 1)


func _on_door_trigger_body_entered(body: Node3D) -> void:
	if body == player:
		var tween = create_tween()
		tween.tween_property(door, "position", Vector3(0, -5, 0), 1)
