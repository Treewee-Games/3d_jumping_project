extends Area3D

@onready var player = get_tree().get_first_node_in_group("player") as CharacterBody3D

func _on_body_entered(body: Node3D) -> void:
	if body == player:
		Checkpoints.set_checkpoint(player.global_transform.origin)
