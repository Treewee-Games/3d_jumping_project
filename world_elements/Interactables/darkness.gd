extends Area3D

@export var fade_time: float = 1.5 #Time to dissolve Darkness
@export var darkness_mesh: MeshInstance3D
@export var darkness_collision_physics: CollisionShape3D
@export var darkness_collision_mesh: CollisionShape3D

func dissolve_darkness()->void:
	var material = darkness_mesh.get_surface_override_material(0)
	var tween = create_tween()
	tween.tween_property(material, "albedo_color",Color(material.albedo_color.r, material.albedo_color.g, material.albedo_color.b, 0), fade_time)
	await tween.finished
	queue_free()
