extends CharacterBody3D
@onready var main_cam: Node3D = $FPScam

@onready var state_machine = $StateMachine
@onready var tp_scam: Camera3D = $FPScam/playerpivot/SpringArm3D/TPScam


#region Variables
#region stats
var max_health = GlobalStats.player_max_health:
	set(value):
		max_health = value
		GlobalStats.player_max_health = max_health
		hud.max_health(value)
var health = GlobalStats.player_health:
	set(value):
		hud.update_health(value)
		health = value
		GlobalStats.player_health = health
		if health > max_health:
			health = max_health
		if health <= 0:
			death()
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
@export var jump_velocity := 10.0
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
#region Menus/HUD
@onready var pause_menu: Control = $PauseMenu
@onready var hud: Control = $Hud
var is_paused: bool = false
#endregion
#region Additional Variables
@onready var skin: Node3D = $lil_skin
@onready var collision_mesh := $collision
@onready var world_checker: RayCast3D = $lil_skin/raycast_holders/world_checker
@onready var wall_check: RayCast3D = $"lil_skin/raycast_holders/wall check"
@onready var ledge_check: RayCast3D = $lil_skin/raycast_holders/ledge_check
@onready var stick_point_holder: Marker3D = $lil_skin/raycast_holders/stick_points/stick_point_holder
@onready var sticking_point: Marker3D = $lil_skin/raycast_holders/stick_points/stick_point_holder/sticking_point
@onready var l_eye: GPUParticles3D = $lil_skin/Armature/Skeleton3D/skullarea/l_eye
@onready var r_eye: GPUParticles3D = $lil_skin/Armature/Skeleton3D/skullarea/r_eye
@onready var l_claws: Node3D = $lil_skin/Armature/Skeleton3D/l_equip/claws
@onready var r_claws: Node3D = $lil_skin/Armature/Skeleton3D/r_equip/claws
var ceiling_check := false
var was_in_air := false
var gravity := Vector3.ZERO
var is_airborne := false
var falling := false
var attack_check : float
var is_dead :bool = false
var blocking: bool = false
#please look over all of these as they are not exports
#endregion
#region Combat
var attacking: bool = false
var is_dodging: bool = false
var is_hit: bool = false
#endregion
#region lock-on mechanic
var target_entered : bool = false
var targeting : bool = false
var targeted : Node3D = null
var orbit_angle: float = 0.0
var radial_distance : float = 0.0
var horizontal_acceleration: float = 2.0
var vertical_acceleration: float = 2.0
var targets: Array = []
@export var camera_lag: float =0.1
@export var position_lag: float = 0.1
@export var input_dead_zone: float = 0.05
@export var lock_on_distance: float = 10
#endregion
#region Signals
@warning_ignore("unused_signal")
signal pausing(value:bool)


#endregion
#region setup
func _ready() -> void:
	hud.setup(max_health, health)
	GlobalStats.activate_power.connect(ability)
	Checkpoints.set_checkpoint(self.global_transform.origin)
	self.connect("pausing", Callable(self, "dialogue_menu"))
	

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		pause_menu.toggle_pause()
	menu_action()
	dialogue_menu(is_paused)

func _physics_process(delta: float) -> void:
	if not is_dead:
		if not pause_menu.is_paused:
			if not is_paused:
				gravity_stuff(delta)
				state_machine._process(delta)
				_jumping_logic(delta)
				activate_abilities()
				can_stand_up()
				attacked()
				block_check()
				move_and_slide()
				if is_hit:
					pass
				else:
					_movement_logic(delta)
				if targeting:
					stop_targeting_thing()
					target_switching()
				else:
					target_thing()
		
	
	if Input.is_action_just_pressed("test button"):
			GlobalStats.unlock_powers("Light Power")
	if Input.is_action_just_pressed("test_heal"):
			GlobalStats.unlock_equipables("Claws")
#endregion
#region jump functions
func _jumping_logic(delta)-> void:
	if Input.is_action_just_pressed("ui_accept") and not state_machine.crouching and not targeting:
		jumping(delta)
	elif Input.is_action_just_pressed("ui_accept") and targeting:
		target_jump_dodge()
		
		
func target_jump_dodge()->void:
	is_dodging = true
		# Get the target position (assuming the enemy's reference is in its first child).
	var target_pos: Vector3 = targeted.get_child(0).global_transform.origin
	# Get the player's position from the skin node (or whichever node represents your character visually).
	var player_pos: Vector3 = skin.global_transform.origin
	# Compute the horizontal vector from the player to the target.
	var to_target: Vector3 = target_pos - player_pos
	to_target.y = 0
	if to_target.length() > 0:
		to_target = to_target.normalized()
	# Compute a right vector (perpendicular to to_target).
	var right_vector: Vector3 = Vector3.UP.cross(to_target).normalized()
	
	# Determine dodge direction.
	# If the player is also providing left/right input, use that to choose the dodge side.
	# Otherwise, default to, say, dodging to the right.
	var horizontal_input: float = Input.get_action_strength("ui_left") - Input.get_action_strength("ui_right")
	print(horizontal_input)
	var dodge_direction: Vector3 = right_vector
	if abs(horizontal_input) > 0.1:
		dodge_direction = right_vector * horizontal_input
		dodge_direction = dodge_direction.normalized()
	
	# Define the dodge magnitudes.
	var dodge_magnitude: float = 10.0  # horizontal speed of the dodge (tweak as needed)
	var vertical_impulse: float = jump_velocity/3  # you can use jump_velocity or another value for the hop
	
	# Apply the dodge: set horizontal velocity and add a vertical impulse.
	print(dodge_direction)
	velocity.x = dodge_direction.x * dodge_magnitude
	velocity.z = dodge_direction.z * dodge_magnitude
	velocity.y = vertical_impulse
	
	await get_tree().create_timer(0.3).timeout
	is_dodging = false

#The actual jump physics are in this, the above is just so that other functions can use the jump physics without messing with anything else
func jumping(delta: float)-> void:
	# Handle jump.
		jump_buffer_counter = JUMP_BUFFER_TIME
		if jump_buffer_counter > 0:
			jump_buffer_counter -= 1 * delta
		if (is_on_floor() or coyote_time_counter > 0) and jump_buffer_counter > 0 and not $Timers/JumpHeightTimer.time_left:
			var tween = create_tween()
			tween.tween_property(skin, "scale", Vector3(.8,.8, .8), 0.1)
			tween.tween_property(skin,"scale", Vector3(1,1,1), .1).set_ease(Tween.EASE_OUT)
			velocity.y = move_toward(0, (jump_velocity), (jump_time))
			was_in_air = true
			coyote_time_counter = 0
			jump_buffer_counter = 0
			if not $Timers/JumpHeightTimer.time_left:
				$Timers/JumpHeightTimer.start()
				jump_velocity = 0
#What happens when they land
func _on_land():
	was_in_air = false #reset airborne state
	var tween = create_tween()
	tween.tween_property(skin, "scale", Vector3(1,.5,1),.1).set_ease(Tween.EASE_IN)
	tween.tween_property(skin, "scale", Vector3(1,1,1),.1).set_ease(Tween.EASE_OUT)
func _on_jump_height_timer_timeout() -> void:
		jump_velocity = 10
#endregion

#region Movement and Gravity
func _movement_logic(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration. 
	var second_input = Input.get_axis("ui_up", "ui_down")
	var third_input = Input.get_axis("ui_left","ui_right")
	var free_input = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var vel_2d: Vector2 = Vector2(velocity.x, velocity.z)
	if not targeting:
		movement_input = free_input.rotated(-tp_scam.global_rotation.y)
		
	else:
		movement_input = free_input
		
	if is_climbing:
		climb_logic(delta)
	
	if is_dodging:
		return
	
	else:
		if state_machine.crouching:
			max_speed = crouch_speed
		elif $Timers/JumpHeightTimer.time_left:
			max_speed = 9.0
		else:
			max_speed = 6.0
			
		#controls movement and direction with camera
		if not movement_input.is_zero_approx():
			if blocking:
				max_speed = 2
			
			
			if not targeting:
				var target_angle = movement_input.angle() + PI/2
				skin.rotation.y = rotate_toward($lil_skin.rotation.y, -target_angle,6.0 * delta)
				var current_acceleration = air_acceleration if is_airborne else acceleration
				speed = lerp(speed, max_speed, delta * current_acceleration)
				vel_2d = movement_input.normalized() * speed
			else:
				max_speed = 3.0
				if third_input == 1 or -1:
					orbit_angle += third_input * horizontal_acceleration * delta
				if second_input == 1 or -1:
					radial_distance += second_input * vertical_acceleration * delta
					radial_distance = clamp(radial_distance, 1.0, 20.0)
				
				var target_pos: Vector3 = targeted.get_child(0).global_transform.origin
				var player_pos: Vector3 = skin.global_transform.origin
				var to_target: Vector3 = target_pos - player_pos
				var right_vector: Vector3 = Vector3.UP.cross(to_target).normalized()
				
				
				var move_direction: Vector3 = (right_vector * -movement_input.x) + (to_target * -movement_input.y)
				
				var current_pos: Vector3 = skin.global_transform.origin
				if move_direction != Vector3.ZERO:
					move_direction = move_direction.normalized()
					
				var current_acceleration = air_acceleration if is_airborne else acceleration
				speed = lerp(speed, max_speed, delta * current_acceleration)
				vel_2d = Vector2(move_direction.x, move_direction.z) * speed
				
				var face_dir: Vector3 = target_pos - current_pos
				face_dir.y = 0
				if face_dir.length() > 0:
					face_dir = face_dir.normalized()
				var desired_yaw = atan2(face_dir.x, -face_dir.z)
				skin.rotation.y = lerp_angle(skin.rotation.y, -desired_yaw, camera_lag)

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
	await get_tree().create_timer(.02).timeout
	if velocity.y < 0: falling = true
#endregion

#region Extra Control Functions DEBUGSSS
func can_stand_up()-> void:
	if world_checker.is_colliding():
		var collider = world_checker.get_collider()
		if collider is StaticBody3D:
			ceiling_check = true
	else:
		ceiling_check = false

		
func heal()-> void:
	max_health += max(0,1)
	await get_tree().create_timer(0.1).timeout
	health = max_health
#endregion

#region climb functions
func climb_logic(delta: float)-> void:
	velocity = Vector3.ZERO #Reset Velocity
	var climb_direction = Input.get_axis("ui_down","ui_up") # Get only vertical input
	var rot = -(atan2(wall_check.get_collision_normal().z, wall_check.get_collision_normal().x) - PI/2)
	if climb_direction != 0:
		velocity = Vector3(0, climb_direction, 0). rotated(Vector3.UP, rot).normalized()
		
	if Input.is_action_just_pressed("ui_accept"):
		is_climbing = false
		jumping(delta)

func _on_ladder_climbing(area) -> void:
	if wall_check.is_colliding():
		if ledge_check.is_colliding():
			is_climbing = true
			stick_point_holder.global_transform.origin = wall_check.get_collision_point()
			self.global_transform.origin.x = sticking_point.global_transform.origin.x
			self.global_transform.origin.z = sticking_point.global_transform.origin.z
			climbable_surface = area.get_parent()
			velocity = Vector3.ZERO
	else:
		is_climbing = false

func _on_ladder_not_climbing() -> void:
	is_climbing = false
	climbable_surface = null
#endregion

#region Ability Scripts
func ability(power: String)->void:
	if power == "Light Power":
		light_on = !light_on
		l_eye.visible = light_on #Turn the actual light on/off
		r_eye.visible = light_on
		$lil_skin/Armature/Skeleton3D/skullarea/l_eye/Light_Area.set_collision_layer_value(7, light_on)
		$lil_skin/Armature/Skeleton3D/skullarea/l_eye/Light_Area.set_collision_mask_value(7, light_on)
func _on_light_area_area_entered(area: Area3D) -> void:
	if area.has_method("dissolve_darkness"):
		area.dissolve_darkness()
#endregion

#region Combat
func attacked()->void:
	if Input.is_action_just_pressed("attack"):
		skin.attack()
		if skin.attacking:
			max_speed += -1
			attacking = true
			attack_check += 1
		if attack_check > 1:
			skin.is_attacking(false)
			attacking = false
			attack_check = 0
func damaged(attacker: CharacterBody3D) -> void:
	if not $Timers/InvulTimer.time_left:
		is_hit = true
		health -= max(0,1)
		var tween = create_tween()
		tween.tween_property(skin, "scale", Vector3(.4,.8,.4),.2)
		tween.tween_property(skin, "scale", Vector3(1,1,1), .2)
		GlobalStats.hit_stop(.015)
		GlobalStats.apply_knockback(self, attacker, 10)
		$Timers/InvulTimer.start()
		await get_tree().create_timer(.2).timeout
		is_hit = false
#endregion

#region Menu Actions
func menu_action()->void:
	if pause_menu.is_paused:
		get_tree().paused = true
		pause_menu.show()
	else:
		get_tree().paused = false
		pause_menu.hide()
		
func dialogue_menu(value:bool)->void:
	is_paused = value
	if is_paused:
		get_tree().paused = is_paused
	else:
		get_tree().paused = is_paused
#endregion



#region ability activations
func activate_abilities()->void:
	if Input.is_action_just_pressed("ability_1"):
		hud.activate_power(0)
	elif Input.is_action_just_pressed("ability_2"):
		hud.activate_power(1)
	elif Input.is_action_just_pressed("ability_3"):
		hud.activate_power(2)
	elif Input.is_action_just_pressed("ability_4"):
		hud.activate_power(3)

#endregion

#region camera lock-on


func _on_targeting_radius_area_entered(area: Area3D) -> void:
	var target = area.get_parent()
	if target.has_method("target_me"):
		targeted = target
		targets.append(targeted)
		
		
		

func target_thing()->void:
	if Input.is_action_just_pressed("snap"):
		if targeted == null:
			return
		var distance = skin.global_transform.origin.distance_to(targeted.get_child(0).global_transform.origin)
		if distance < lock_on_distance:
			main_cam.set_lock_on_target(targeted)
			targeted.target_me()
			targeting = true
		
		

func stop_targeting_thing()->void:
	if Input.is_action_just_pressed("snap"):
		targeted.not_targeted()
		main_cam.release_lock_on()
		targeting = false
		var to_target = targeted.get_child(0).global_transform.origin - skin.global_transform.origin
		to_target.y = 0
		radial_distance = to_target.length()
	# Compute the angle from the target to the player.
	# (This gives a baseline from which horizontal input will adjust the orbit.)
		orbit_angle = atan2(skin.global_transform.origin.x - targeted.get_child(0).global_transform.origin.x,
		skin.global_transform.origin.z - targeted.get_child(0).global_transform.origin.z)
	#
#
#
func _on_targeting_radius_area_exited(area: Area3D) -> void:
	var target = area.get_parent()
	if target == targeted:
		targeting = false
		targeted.not_targeted()
		main_cam.release_lock_on()
		if target in targets:
			targets.erase(target)
		if targeting == false:
			await get_tree().create_timer(.4).timeout
			targets = []
			
			
func switch_targets(direction: int)->void:
	if targets.size() <= 1:
		return
	var current_index = targets.find(targeted)
	var new_index = (current_index + direction + targets.size()) % targets.size()
	
	if targeted:
		targeted.not_targeted()
	
	targeted = targets[new_index]
	
	targeted.target_me()
	main_cam.set_lock_on_target(targeted)
	
	
func target_switching()->void:
	if Input.is_action_just_pressed("pan_left"):
		switch_targets(-1)
	if Input.is_action_just_pressed("pan_right"):
		switch_targets(1)
	var distance = skin.global_transform.origin.distance_to(targeted.get_child(0).global_transform.origin)
	if distance > lock_on_distance:
		targeted.not_targeted()
		main_cam.release_lock_on()
		targeting = false
#endregion

#region respawning/death/saving
func respawn()->void:
	if is_dead:
		health = max_health
		is_dead = false
	global_transform.origin = Checkpoints.get_checkpoint()
	velocity = Vector3.ZERO
	
func death()->void:
	is_dead = true
	await  get_tree().create_timer(1).timeout
	respawn()
#endregion

#region Moving Blocks
func block_check()->void:
	var block_checking = wall_check.get_collider()
	if block_checking and block_checking.is_in_group("moving_blocks"):
		if Input.is_action_pressed("Use"):
			blocking = true
			block_checking.call("start_push", skin)
		if Input.is_action_just_released("Use"):
			blocking = false
			block_checking.call("stop_push")
#endregion
