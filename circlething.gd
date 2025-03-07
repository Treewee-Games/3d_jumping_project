extends Node3D

@onready var meshy: MeshInstance3D = $Circle
@onready var statics: StaticBody3D = $Circle/StaticBody3D

func _ready() -> void:
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(meshy, "rotation_degrees", Vector3(0,360,0), 10)
	tween.tween_property(meshy, "rotation_degrees", Vector3(0,720,0), 10)
	tween.tween_property(meshy, "rotation_degrees", Vector3(0,360,0), 30)
	tween.tween_property(meshy, "rotation_degrees", Vector3(0,0,0), 30)



func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		body.reparent(self, true)  # Make player a child of the platform


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		body.reparent(get_tree().get_root())  # Reset player to the main scene


func _on_rotation_velocity_timer_timeout() -> void:
	statics.constant_angular_velocity = Vector3(0, -12,0)
