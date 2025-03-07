extends Area3D

@onready var player = get_tree().get_first_node_in_group("player") as CharacterBody3D
@export var power_name : String = "Light Power"

func _on_body_entered(body: Node3D) -> void:
	if body == player:
		GlobalStats.unlock_powers(power_name)
		queue_free()
