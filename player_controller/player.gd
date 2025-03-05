extends CharacterBody3D

@export var camera:= Camera3D
@onready var state_machine = $StateMachine

#region stats
var health = GlobalStats.player_health:
	set(value):
		health = value
		if health <= 0:
			get_tree().quit()
var souls = GlobalStats.soul_count
var keys = GlobalStats.key_count
var boss_key = GlobalStats.boss_key_count

#endregion

#region movment/climblogic variables
@export_category("Move Logic")
var speed := 0.0
var movement_input := Vector2.ZERO
var last_movement_input := Vector2(0,1)
var is_climbing := false
var climbable_surface : Node3D = null #Reference to ladder or vine
@export var acceleration := 10.0
@export var deceleration := 15.0
@export var air_acceleration := 5.0
@export var air_deceleration := 8.0
@export var crouch_speed := 2.0
@export var max_speed := 6.0
@export var climb_speed := 2.0
#endregion
#region jumplogic variables
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
#endregion
#region Light Ability
@export var light_area: Area3D
var light_on := false
#endregion
#region Additional Variables
@onready var skin: Node3D = $lil_skin
@onready var collision_mesh := $collision
@onready var world_checker: RayCast3D = $world_checker
@onready var l_eye: GPUParticles3D = $lil_skin/Armature/Skeleton3D/skullarea/l_eye
@onready var r_eye: GPUParticles3D = $lil_skin/Armature/Skeleton3D/skullarea/r_eye
var ceiling_check := false
var was_in_air := false
var gravity := Vector3.ZERO
var is_airborne := false
var falling := false
#please look over all of these as they are not exports
#endregion

func _physics_process(delta: float) -> void:
	gravity_stuff(delta)
	state_machine._process(delta)
	_jumping_logic(delta)
	_movement_logic(delta)
	toggle_light()
	can_stand_up()

#region jump functions
func _jumping_logic(delta)-> void:
	if Input.is_action_just_pressed("ui_accept") and not state_machine.crouching:
		jumping(delta)
#The actual jump physics are in this, the above is just so that other functions can use the jump physics without messing with anything else
func jumping(delta: float)-> void:
	# Handle jump.
		jump_buffer_counter = JUMP_BUFFER_TIME
		if jump_buffer_counter > 0:
			jump_buffer_counter -= 1 * delta
			skin.set_anim_speed(jump_buffer_counter)
		if (is_on_floor() or coyote_time_counter > 0) and jump_buffer_counter > 0:
			var jump_height:int = (jump_count)*2
			var tween = create_tween()
			tween.tween_property(skin, "scale", Vector3(.8,.8, .8), 0.1)
			tween.tween_property(skin,"scale", Vector3(1,1,1), .1).set_ease(Tween.EASE_OUT)
			velocity.y = move_toward(0, (jump_velocity + jump_height), (jump_time + jump_height))
			was_in_air = true
			coyote_time_counter = 0
			jump_buffer_counter = 0
			jump_count += 1
			jump_heights(jump_count)
			if not $Timers/JumpHeightTimer.time_left:
				$Timers/JumpHeightTimer.start()
#Varying jump height
func jump_heights(value: int)->void:
	if value > 2 and is_on_floor() and not $Timers/JumpHeightTimer.time_left:
		jump_count = 0
	if value > 3 and is_on_floor():
		jump_count = 0
#What happens when they land
func _on_land():
	was_in_air = false #reset airborne state
	var tween = create_tween()
	tween.tween_property(skin, "scale", Vector3(1,.5,1),.1).set_ease(Tween.EASE_IN)
	tween.tween_property(skin, "scale", Vector3(1,1,1),.1).set_ease(Tween.EASE_OUT)
func _on_jump_height_timer_timeout() -> void:
		jump_count = 0
#endregion

#region Movement and Gravity
func _movement_logic(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration. 
	movement_input = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down").rotated(-camera.global_rotation.y)
	var vel_2d: Vector2 = Vector2(velocity.x, velocity.z)
	
	if is_climbing:
		climb_logic(delta)
	
	else:
		if state_machine.crouching:
			max_speed = crouch_speed
		else:
			max_speed = 6.0
		
		#controls movement and direction with camera
		if not movement_input.is_zero_approx():
		# Rotate input direction & apply movement
			var target_angle = -movement_input.angle() + TAU
			skin.rotation.y = rotate_toward($lil_skin.rotation.y, target_angle,6.0 * delta)
			var current_acceleration = air_acceleration if is_airborne else acceleration
			speed = lerp(speed, max_speed, delta * current_acceleration)
			vel_2d = movement_input.normalized() * speed

	# Smooth deceleration when no input
		else:
			var current_deceleration = air_deceleration if is_airborne else deceleration
			speed = lerp(speed, 0.0, delta * current_deceleration)
			vel_2d = vel_2d.move_toward(Vector2.ZERO, deceleration * delta)

		
# Apply final movement
	velocity.x = vel_2d.x
	velocity.z = vel_2d.y
	
# Store last movement input safely
	if not movement_input.is_zero_approx():
			last_movement_input = movement_input  # No need to multiply by 2
	move_and_slide()
func gravity_stuff(delta)-> void:
	if not is_on_floor():
		gravity = get_gravity() * delta # Add the gravity.
		velocity += gravity
		is_airborne = true
	
		if Input.is_action_just_released("ui_accept"):
			velocity.y = move_toward(0, (-jump_velocity/2), (jump_time*6)) #Add variable jump height
	coyote_time_counter -= delta
	coyote_time_counter = max(0,coyote_time_counter)
	
	if is_on_floor():
		if is_airborne:
			_on_land()
		coyote_time_counter = COYOTE_TIME #Reset coyote timer when grounded
		is_airborne = false
		falling = false
	if velocity.y < 0: falling = true
#endregion

#region Extra Control Functions
func can_stand_up()-> void:
	if world_checker.is_colliding():
		var collider = world_checker.get_collider()
		if collider is StaticBody3D:
			ceiling_check = true
	else:
		ceiling_check = false
func damaged() -> void:
	if not $Timers/InvulTimer.time_left:
		health -= max(0,1)
		#var tween = create_tween()
		#tween.tween_property(mesh, "scale", Vector3(.4,.4,.4),.1)
		#tween.tween_property(mesh, "scale", Vector3(1,1,1), .1)
		$Timers/InvulTimer.start()
#endregion

#region climb functions
func climb_logic(delta: float)-> void:
	velocity = Vector3.ZERO #Reset Velocity
	var climb_direction = Input.get_axis("ui_down","ui_up") # Get only vertical input
	
	if climb_direction != 0:
		velocity.y = climb_direction * climb_speed
		
	if Input.is_action_just_pressed("ui_accept"):
		is_climbing = false
		jumping(delta)

func _on_ladder_climbing(area) -> void:
	is_climbing = true
	climbable_surface = area.get_parent()
	velocity = Vector3.ZERO

func _on_ladder_not_climbing() -> void:
	is_climbing = false
	climbable_surface = null
#endregion

#region Light Ability
func toggle_light()->void:
	if Input.is_action_just_pressed("ability_1"):
		light_on = !light_on
		l_eye.visible = light_on #Turn the actual light on/off
		r_eye.visible = light_on
		light_area.monitoring = light_on
		light_area.monitorable = light_on
		light_area.set_collision_layer_value(7, light_on)
func _on_light_area_area_entered(area: Area3D) -> void:
	if area.has_method("dissolve_darkness"):
		area.dissolve_darkness()
#endregion
