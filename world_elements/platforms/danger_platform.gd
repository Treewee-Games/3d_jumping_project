extends "res://world_elements/platforms/platform.gd"

@warning_ignore("unused_signal")
signal damaged

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body == player:
		if body.has_method("damaged"):
			player.damaged()
