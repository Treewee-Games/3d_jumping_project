extends "res://world_elements/collectibles/collectible.gd"
@onready var heart: Node3D = $RigidBody3D/heart


func item_function()->void:
	player.boss_key += 1
	queue_free()

func _ready() -> void:
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(heart, "scale", Vector3(3, 3, 3), .4)
	tween.tween_property(heart, "scale", Vector3(2.9, 2.9, 2.9), .4)
