extends "res://world_elements/collectibles/collectible.gd"

func item_function():
	player.keys += 1
	queue_free()
