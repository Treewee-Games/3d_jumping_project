extends "res://world_elements/collectibles/collectible.gd"


func item_function()->void:
	player.souls += 1
	queue_free()
