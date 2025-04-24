extends Node3D


@export var button_title: String = "1"
@onready var button = $button
@onready var player = get_tree().get_first_node_in_group("player") as CharacterBody3D
@export var is_a_block_button : bool = false
@export var is_a_door_button: bool = false
@export var is_a_single_use: bool = false
var button_is_pressed: bool = false
@warning_ignore("unused_signal")
signal trigger_effect
@warning_ignore("unused_signal")
signal button_effect(String)


func _on_area_3d_body_entered(body: Node3D) -> void:
	var shader_color = $button/Eyeball.get_surface_override_material(0)
	if not button_is_pressed:
		if body == player:
			if not is_a_block_button:
				if not is_a_door_button:
					var tween = create_tween()
					tween.tween_property(shader_color, "albedo_color", Color.RED, .1)
					tween.tween_property(button, "scale", Vector3(.7, 0.1, .7), .3)
					await tween.finished
					emit_signal("trigger_effect")
				else:
					var tween = create_tween()
					tween.tween_property(shader_color, "albedo_color", Color.RED, .1)
					tween.tween_property(button, "scale", Vector3(.7, 0.1, .7), .3)
					await tween.finished
					emit_signal("button_effect",button_title)
		if body.is_in_group("moving_blocks"):
			if is_a_block_button:
				var tween = create_tween()
				tween.tween_property(shader_color, "albedo_color", Color.RED, .1)
				tween.tween_property(button, "scale", Vector3(.7, 0.1, .7), .3)
				await tween.finished
				emit_signal("trigger_effect")


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body == player:
		var shader_color = $button/Eyeball.get_surface_override_material(0)
		if not is_a_single_use:
			button_is_pressed = true
			var tween = create_tween()
			tween.tween_property(button, "scale", Vector3(.7, 0.8, .7), .2)
			tween.tween_property(button, "scale", Vector3(.7, 0.3, .7), .4)
			tween.tween_property(button, "scale", Vector3(.7, 0.5, .7), .8)
			tween.tween_property(shader_color, "albedo_color", Color.WHITE, .4)
			await tween.finished
			button_is_pressed = false
		else:
			button_is_pressed = true
