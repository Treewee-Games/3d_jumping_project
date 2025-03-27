extends "res://world_elements/collectibles/collectible.gd"

@onready var heart: Node3D = $RigidBody3D/heart


func item_function():
	player.keys += 1
	queue_free()


func _ready() -> void:
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(heart, "scale", Vector3(1, 1, 1), .4)
	tween.tween_property(heart, "scale", Vector3(.9, .9, .9), .4)
