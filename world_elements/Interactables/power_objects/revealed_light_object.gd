extends Area3D

@export var reveal_time := 1.0
@export var hide_time := 1.0
@export var hidden_object : MeshInstance3D
@export var static_body : StaticBody3D
@onready var hidden_sprites: GPUParticles3D = $GPUParticles3D

var light_count := 0


func _on_area_entered(area: Area3D) -> void:
	if area.is_in_group("Light Area"):
		print("yep")
		light_count += 1
		if light_count == 1:
			reveal_object()

func _on_area_exited(area: Area3D) -> void:
	if area.is_in_group("Light Area"):
		print("lame")
		light_count = max(0, light_count-1)#Decrease the light_count
		if light_count ==0:
			hide_object()

func reveal_object()->void:
	var material = hidden_object.get_surface_override_material(0)
	var tween = create_tween()
	tween.tween_property(material, "albedo_color", Color(material.albedo_color.r, material.albedo_color.g, material.albedo_color.b, 1), reveal_time)#Fade in
	static_body.set_collision_layer_value(1, true)
	hidden_sprites.hide()

func hide_object():
	var material = hidden_object.get_surface_override_material(0)
	var tween = create_tween()
	tween.tween_property(material, "albedo_color", Color(material.albedo_color.r, material.albedo_color.g, material.albedo_color.b, 0), hide_time)
	if static_body.get_collision_layer_value(1) == true:
		await get_tree().create_timer(0.4).timeout
		if light_count == 0:
			static_body.set_collision_layer_value(1, false)
			hidden_sprites.show()
