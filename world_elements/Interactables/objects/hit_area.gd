extends Area3D

signal trigger_hit

func on_hit(source):
	trigger_hit.emit()
