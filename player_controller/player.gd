extends CharacterBody3D

@export var camera:= Camera3D

#movmentlogic variables
@export_category("Move Logic")
var speed := 0.0
var movement_input := Vector2.ZERO
var last_movement_input := Vector2(0,1)
@export var acceleration := 10.0
@export var deceleration := 15.0
@export var max_speed := 1.0
#jumplogic variables
@export_category("Jump Logic")
@export var jump_velocity := 4.5
@export var jump_time := 3.5
const COYOTE_TIME := 10.0
const JUMP_BUFFER_TIME := 6.0
var jump_count := 0
var last_grounded_time := 0.0
var last_jump_time = -JUMP_BUFFER_TIME
var coyote_time_counter := 0.0
var jump_buffer_counter := 0.0
#additional variables
@onready var mesh := $mesh
@onready var collision_mesh := $collision
var was_in_air := false
var gravity := Vector3.ZERO

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		gravity = get_gravity() * delta # Add the gravity.
		velocity += gravity
		if Input.is_action_just_released("ui_accept"):
			velocity.y = move_toward(0, (-jump_velocity/2), (jump_time*6)) #Add variable jump height
	if is_on_floor() and was_in_air:
		_on_land()
		coyote_time_counter = COYOTE_TIME #Reset coyote timer when grounded
	else:
		coyote_time_counter = max(0, coyote_time_counter -1)
	_jumping_logic()
	_movement_logic(delta)
	actions()
# Handle jump.
func _jumping_logic()-> void:
	if Input.is_action_just_pressed("ui_accept"):
		jump_buffer_counter = JUMP_BUFFER_TIME
		if jump_buffer_counter > 0:
			jump_buffer_counter -= 1
		if (is_on_floor() or coyote_time_counter > 0) and jump_buffer_counter > 0:
			var jump_height:int = (jump_count)*2
			var tween = create_tween()
			tween.tween_property(mesh, "scale", Vector3(.8,.8, .8), 0.1)
			tween.tween_property(mesh,"scale", Vector3(1,1,1), .1).set_ease(Tween.EASE_OUT)
			velocity.y = move_toward(0, (jump_velocity + jump_height), (jump_time + jump_height))
			was_in_air = true
			coyote_time_counter = 0
			jump_buffer_counter = 0
			jump_count += 1
			jump_heights(jump_count)
			if not $Timers/JumpHeightTimer.time_left:
				$Timers/JumpHeightTimer.start()

# Get the input direction and handle the movement/deceleration. 
func _movement_logic(delta: float) -> void:
	movement_input = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down").rotated(-camera.global_rotation.y)
	var vel_2d: Vector2 = Vector2(velocity.x, velocity.z)
	
	#controls movement and direction with camera
	if not movement_input.is_zero_approx():
	# Rotate input direction & apply movement
		speed = lerp(speed, max_speed, delta * acceleration)
		vel_2d = movement_input.normalized() * speed

	# Smooth deceleration when no input
	else:
		speed = lerp(speed, 0.0, delta * deceleration)
		vel_2d = vel_2d.move_toward(Vector2.ZERO, deceleration * delta)

		
# Apply final movement
	velocity.x = vel_2d.x
	velocity.z = vel_2d.y
	
# Store last movement input safely
	if not movement_input.is_zero_approx():
			last_movement_input = movement_input  # No need to multiply by 2
	move_and_slide()

func jump_heights(value: int)->void:
	if value > 2 and is_on_floor() and not $Timers/JumpHeightTimer.time_left:
		jump_count = 0
	if value > 3 and is_on_floor():
		jump_count = 0

func _on_land():
	was_in_air = false #reset airborne state
	var tween = create_tween()
	tween.tween_property(mesh, "scale", Vector3(1,.95,1),.01)
	tween.tween_property(collision_mesh, "scale", Vector3(1,.95,1),.01)
	tween.tween_property(mesh, "position", Vector3(0,-.1,0),.1)
	tween.tween_property(collision_mesh, "position", Vector3(0,-.1,0),.01)

	tween.tween_property(mesh, "scale", Vector3(1,1,1),.05)
	tween.tween_property(collision_mesh, "scale", Vector3(1,1,1),.05)
	tween.tween_property(mesh, "position", Vector3(0,0,0),.05)
	tween.tween_property(collision_mesh, "position", Vector3(0,0,0),.05)

func _on_jump_height_timer_timeout() -> void:
	jump_count = 0
	
func actions()->void:
	if Input.is_action_pressed("crouch") and is_on_floor():
		var tween = create_tween()
		tween.tween_property(mesh, "position", Vector3(0,-.5,0),.01)
		tween.tween_property(collision_mesh, "position", Vector3(0,-.5,0),.01)
		tween.tween_property(mesh, "scale", Vector3(1,.5,1),.1)
		tween.tween_property(collision_mesh, "scale", Vector3(1,.5,1),.1)
	if Input.is_action_just_released("crouch") and is_on_floor():
		var tween = create_tween()
		tween.tween_property(mesh, "position", Vector3(0,0,0),.01)
		tween.tween_property(collision_mesh, "position", Vector3(0,0,0),.01)
		tween.tween_property(mesh, "scale", Vector3(1,1,1),.1)
		tween.tween_property(collision_mesh, "scale", Vector3(1,1,1),.1)
