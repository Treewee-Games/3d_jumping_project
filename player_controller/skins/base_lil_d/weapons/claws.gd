extends Node3D


func _process(_delta: float) -> void:
	emitting_trail()

func emitting_trail()->void:
	$trail.emitting = self.visible
