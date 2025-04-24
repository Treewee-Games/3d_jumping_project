extends Area3D
@export var fog_area: FogVolume
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
	var fog = fog_area.material
	var tween = create_tween()
	tween.tween_property(fog, "density", 0, 2)
	
func hide_object()->void:
	var fog = fog_area.material
	var tween = create_tween()
	tween.tween_property(fog, "density", 8, 2)
