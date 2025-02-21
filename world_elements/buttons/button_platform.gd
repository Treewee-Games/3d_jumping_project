extends Node3D

@onready var platform: StaticBody3D = $platform
@onready var origin: Marker3D = $origin

func _on_button_trigger_effect() -> void:
	print(origin.global_position)
	var tween = create_tween()
	tween.tween_property(platform, "position",  Vector3(0, 1, 0), 5)
	


func _on_button_exit_effect() -> void:
	var postion = origin.global_position
	var tween = create_tween()
	tween.tween_property(platform, "position", (platform.position - postion), 5)
