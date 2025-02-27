extends "res://world_elements/platforms/platform.gd"

@onready var player = get_tree().get_first_node_in_group("player")

@warning_ignore("unused_signal")
signal damaged

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body == player:
		emit_signal("damaged")
