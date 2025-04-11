extends Area3D

@onready var player = get_tree().get_first_node_in_group("player") as CharacterBody3D
@export var power_name : String = "Light Power"
@export var equipable_name: String = "Claws"

func _on_body_entered(body: Node3D) -> void:
	if body == player:
		if power_name:
			GlobalStats.unlock_powers(power_name)
			queue_free()
		if equipable_name:
			GlobalStats.unlock_equipables(equipable_name)
			queue_free()
			
	
