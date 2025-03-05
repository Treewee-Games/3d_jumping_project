extends Node3D

@onready var player = get_tree().get_first_node_in_group("player")

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body == player:
		item_function()
		
func item_function():
	pass
