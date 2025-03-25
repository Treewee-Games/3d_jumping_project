extends Node3D

@onready var door = $StaticBody3D
@onready var player = get_tree().get_first_node_in_group("player") as CharacterBody3D
@export var door_locked := false
var unlock_it := false
var player_inside := false
@onready var door_creature_round_2: Node3D = $StaticBody3D/door_creature_round2


func _on_door_trigger_body_exited(body: Node3D) -> void:
	if body == player:
		player_inside = false
		close_door()



func _on_door_trigger_body_entered(body: Node3D) -> void:
	if body == player:
		player_inside = true
		
func _process(_delta: float) -> void:
	if player_inside and Input.is_action_just_pressed("Use"):
		interact_with_door()
	if door_locked:
		door_creature_round_2.show()
	if not door_locked:
		door_creature_round_2.hide()

func interact_with_door():
	if player.keys > 0 and door_locked:
		door_locked = false
		player.keys -= 1
		
	if not door_locked:
		open_door()

func open_door():
		var tween = create_tween()
		tween.tween_property(door, "position", Vector3(0, -5, 0), 1)

func close_door():
		var tween = create_tween()
		tween.tween_property(door, "position", Vector3(0, 0, 0), 1)
