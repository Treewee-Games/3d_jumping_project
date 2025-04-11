extends Area3D

@export var fade_time: float = 1.5 #Time to dissolve Darkness
@export var respawn_timer: float = 5.0
@export var darkness_mesh: MeshInstance3D
@export var darkness_collision_physics: CollisionShape3D
@export var darkness_collision_mesh: CollisionShape3D

var original_material: StandardMaterial3D

func _ready() -> void:
	original_material = darkness_mesh.get_surface_override_material(0).duplicate()

func dissolve_darkness()->void:
	var material = darkness_mesh.get_surface_override_material(0)
	var tween = create_tween()
	tween.tween_property(material, "albedo_color",Color(material.albedo_color.r, material.albedo_color.g, material.albedo_color.b, 0), fade_time)
	await tween.finished
	darkness_mesh.visible = false
	darkness_collision_mesh.disabled = true
	darkness_collision_physics.disabled = true
	
	await get_tree().create_timer(respawn_timer).timeout
	
	respawn_darkness()
	
func respawn_darkness()->void:
	var material = darkness_mesh.get_surface_override_material(0)
	material.albedo_color.a = 0
	
	darkness_mesh.visible = true
	darkness_collision_mesh.disabled = false
	darkness_collision_physics.disabled = false
	
	var tween = create_tween()
	tween.tween_property(material, "albedo_color",Color(material.albedo_color.r, material.albedo_color.g, material.albedo_color.b, 1), fade_time)
