extends CharacterBody3D
@onready var target: Marker3D = $target


func _ready() -> void:
	print("I am an NPC boi")
	target.hide()


func target_me()->void:
	target.show()
	
func not_targeted()->void:
	target.hide()
	
func tweening(object:Node3D, timing: float)->void:
	var tween = create_tween()
	tween.tween_property(object, "scale", Vector3(.7, .5, 1), timing)
	tween.tween_property(object, "scale", Vector3(1, 1, 1), timing)
