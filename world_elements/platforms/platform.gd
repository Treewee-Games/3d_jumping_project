extends Node3D

@onready var platform: StaticBody3D = $platform
@onready var origin: Marker3D = $origin

@export var button_or_not := false
var platform_up := false
@export var move_distance_y := 1.0
@export var move_distance_x := 0.0
@export var move_distance_z := 0.0
@export var move_time := 2.0
@export var timing := 2.0

func _physics_process(_delta: float) -> void:
	platform_movement_up()

func _on_button_trigger_effect() -> void:
	if button_or_not:
		var target_position = platform.global_position + Vector3(move_distance_x, move_distance_y, move_distance_z) #Move Up
		var tween = create_tween()
		tween.tween_property(platform, "global_position", target_position , move_time).set_ease(Tween.EASE_IN_OUT)
		platform.constant_linear_velocity = Vector3(move_distance_x, move_distance_y, move_distance_z)/move_time

func _on_button_exit_effect() -> void:
	if button_or_not:
		await get_tree().create_timer(timing).timeout
		var tween = create_tween()
		tween.tween_property(platform, "global_position", origin.global_position, move_time).set_ease(Tween.EASE_IN_OUT)
		platform.constant_linear_velocity = Vector3(-move_distance_x, -move_distance_y, -move_distance_z)/move_time

func platform_movement_up()-> void:
	if not button_or_not:
		if not platform_up:
			platform_up = true
			var target_position = platform.global_position + Vector3(move_distance_x, move_distance_y, move_distance_z) #Move Up
			var tween = create_tween()
			tween.tween_property(platform, "global_position", target_position , move_time).set_ease(Tween.EASE_IN_OUT)
			platform.constant_linear_velocity = Vector3(move_distance_x, move_distance_y, move_distance_z)/move_time
			await get_tree().create_timer(timing).timeout
			platform_movement_down()


func platform_movement_down()-> void:
	var tween = create_tween()
	tween.tween_property(platform, "global_position", origin.global_position, move_time)
	platform.constant_linear_velocity = Vector3(-move_distance_x, -move_distance_y, -move_distance_z)/move_time
	await get_tree().create_timer(timing).timeout
	platform_up = false
