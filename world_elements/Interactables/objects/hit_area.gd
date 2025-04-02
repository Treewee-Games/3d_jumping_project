extends Area3D

signal trigger_hit

func on_hit(_source):
	trigger_hit.emit()
