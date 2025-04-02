extends Node3D
@onready var hit_cast: RayCast3D = $RayCast3D
var hitting : bool = false
var collision : bool = false


func _ready() -> void:
	hit_cast.set_collision_mask_value(3, collision)
	hit_cast.set_collision_mask_value(4, collision)


func _process(_delta: float) -> void:
	emitting_trail()
	hitting_cast()

func emitting_trail()->void:
	$trail.emitting = self.visible

func hitting_cast()->void:
	hit_cast.set_collision_mask_value(3, collision)
	hit_cast.set_collision_mask_value(4, collision)
	var hit = hit_cast.get_collider()
	if hit and hit.is_in_group("destructible"):
		hit.call("on_hit", self)
	if hit and hit.is_in_group("Enemies"):
		hit.call("on_hit", self)

		
		

func set_collision(value: bool)->void:
	collision = value
	
