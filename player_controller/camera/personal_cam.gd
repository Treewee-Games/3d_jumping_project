extends Node3D

@onready var player = get_tree().get_first_node_in_group("player") as CharacterBody3D
@export var min_limit_x: float
@export var max_limit_x: float
@export var horizontal_acceleration := 2.0
@export var vertical_acceleration := 1.0
@export var smooth_factor: float = 0.1
@export var auto_rotate_speed: float = 1.0
@export var auto_rotate_delay: float = 1.0
@export var test_rotation: float = 30.0
#region checks
@onready var wall_checks_behind: RayCast3D = $playerpivot/SpringArm3D/TPScam/wall_checks
@onready var wall_checks_below: RayCast3D = $playerpivot/SpringArm3D/TPScam/wall_checks2
@onready var wall_checks_right: RayCast3D = $playerpivot/SpringArm3D/TPScam/wall_checks3
@onready var wall_checks_4_left: RayCast3D = $playerpivot/SpringArm3D/TPScam/wall_checks4
#endregion
var target_rot: Vector2 = Vector2.ZERO
var time_since_last_input: float = 0.0

# Lock–on variables.
var is_lock_on: bool = false
var lock_on_target: Node3D = null


func _ready() -> void:
	target_rot.x = rotation.x
	target_rot.y = rotation.y

func _process(delta: float) -> void:
	var skin = player.get_child(1)
	var joy_dir = Input.get_vector("pan_left", "pan_right", "pan_up", "pan_down")
	var movement_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if is_lock_on and lock_on_target:
		# In lock–on mode, we force the player's skin to face the target.
		var desired_skin_yaw = skin.rotation.y + 80
		target_rot.y = desired_skin_yaw  # Immediately override the target rotation.
		self.rotation.y = desired_skin_yaw      # And directly assign to the camera rig's rotation.
		# Smoothly rotate the skin toward the target
		self.rotation.x = lerp_angle(rotation.x, target_rot.x + test_rotation, smooth_factor)
	
	
	
	else:
		if joy_dir.length() > 0:
			time_since_last_input = 0.0
			# Update the target rotation based on input.
			# Horizontal input affects yaw.
			target_rot.y += joy_dir.x * horizontal_acceleration * delta
			# Vertical input affects pitch.
			target_rot.x += joy_dir.y * vertical_acceleration * delta
			# Clamp the vertical (pitch) rotation.
			target_rot.x = clamp(target_rot.x, min_limit_x, max_limit_x)
		if movement_dir.length() > 0:
			time_since_last_input = 0.0
		else:
			time_since_last_input += delta
			
			if time_since_last_input > auto_rotate_delay:
				# Auto rotate: slowly move the target yaw to match the player's rotation.
				# This makes the camera gradually move to face behind the player.
				target_rot.y = lerp_angle(target_rot.y, (skin.rotation.y+80), auto_rotate_speed * delta)
	
	# Smoothly interpolate the current rotation toward the target rotation.
	rotation.y = lerp_angle(rotation.y, target_rot.y, smooth_factor)
	rotation.x = lerp_angle(rotation.x, target_rot.x, smooth_factor)
	
	
	
	
	
	
# --- Public API for lock–on control ---
func set_lock_on_target(target: Node3D) -> void:
	is_lock_on = true
	lock_on_target = target
	

func release_lock_on() -> void:
	is_lock_on = false
	lock_on_target = null
	
	
	
	
	
	
	
	#rotate_from_vector(joy_dir * delta * Vector2(horizontal_acceleration, 0), (joy_dir * delta * Vector2(0, vertical_acceleration)))


		
#func rotate_from_vector(v: Vector2, vy: Vector2):
	#if v.length() == 0: return
	#rotation.y += v.x
	#rotation.x += vy.y
	#rotation.x = clamp(rotation.x, min_limit_x, max_limit_x)
