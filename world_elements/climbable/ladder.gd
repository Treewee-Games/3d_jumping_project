extends Node3D

@onready var player = get_tree().get_first_node_in_group("player") as CharacterBody3D
@onready var climbable_area: Area3D = $"StaticBody3D/climbable area"
var player_inside: bool = false

@warning_ignore("unused_signal")
signal climbing(area: Area3D)
@warning_ignore("unused_signal")
signal not_climbing

func _on_climbable_area_body_entered(body: Node3D) -> void:
	if body == player:
		player_inside = true


func _physics_process(delta: float) -> void:
		if Input.is_action_just_pressed("Use") and player_inside:
			print("Did this happen")
			emit_signal("climbing", climbable_area)


func _on_climbable_area_body_exited(body: Node3D) -> void:
	if body == player:
		player_inside = false
		emit_signal("not_climbing")
