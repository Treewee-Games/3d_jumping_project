extends Node3D

@onready var player = get_tree().get_first_node_in_group("player") as CharacterBody3D
@onready var climbable_area: Area3D = $"StaticBody3D/climbable area"


signal climbing(area: Area3D)
signal not_climbing

func _on_climbable_area_body_entered(body: Node3D) -> void:
	if body == player:
		emit_signal("climbing", climbable_area)



func _on_climbable_area_body_exited(body: Node3D) -> void:
	if body == player:
		emit_signal("not_climbing")
