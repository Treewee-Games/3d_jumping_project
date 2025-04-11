extends Area3D
@export var decal_image: Texture
@onready var decal: Decal = $Decal
var showing: bool = false

func _ready() -> void:
	decal.texture_albedo = decal_image
	decal.albedo_mix = 0

func return_to_normal()->void:
	var tween = create_tween()
	tween.tween_property(decal, "albedo_mix", 0, .7)
	await tween.finished
func reveal()->void:
	var tween = create_tween()
	tween.tween_property(decal, "albedo_mix", 1, .7)
	await tween.finished

func _on_area_entered(area: Area3D) -> void:
	if area.is_in_group("Light Area"):
		reveal()


func _on_area_exited(area: Area3D) -> void:
	if area.is_in_group("Light Area"):
		return_to_normal()
