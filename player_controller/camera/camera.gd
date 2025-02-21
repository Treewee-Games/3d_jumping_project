extends SpringArm3D

@export var min_limit_x: float
@export var max_limit_x: float
@export var horizontal_acceleration := 2.0
@export var vertical_acceleration := 1.0
@export var mouse_acceleration := 0.005

func _process(delta: float) -> void:
	var joy_dir = Input.get_vector("pan_left", "pan_right", "pan_up", "pan_down")
	rotate_from_vector(joy_dir * delta * Vector2(horizontal_acceleration, 0), (joy_dir * delta * Vector2(0, vertical_acceleration)))


		
func rotate_from_vector(v: Vector2, vy: Vector2):
	if v.length() == 0: return
	rotation.y += v.x
	rotation.x += vy.y
	rotation.x = clamp(rotation.x, min_limit_x, max_limit_x)
