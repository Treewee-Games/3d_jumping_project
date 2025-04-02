extends Node3D

enum CameraState { FREE, LOCK_ON }
var state: int = CameraState.FREE

# -- Exported properties for tweaking the feel --
@export_range(5, 20)
var target_distance: float = 10.0          # Distance from the pivot.
@export var rotation_speed: float = 5.0      # How fast the pivot rotates (lock-on).
@export var vertical_speed: float = 3.0      # How fast the arm rotates vertically.
@export var free_sensitivity: float = 0.5    # Input sensitivity in free mode.
@export var vertical_clamp_min: float = -30.0
@export var vertical_clamp_max: float = 60.0

# -- References to rig nodes --
@onready var pivot: Node3D = $CameraPivot
@onready var arm: Node3D = $CameraPivot/CameraArm
@onready var cam: Camera3D = $CameraPivot/CameraArm/Camera

# The current lock-on target. (Set by your player code when a target is acquired.)
var lock_target: Node3D = null

func _physics_process(delta: float) -> void:
	# Update the rig’s position to follow the player.
	# (If the CameraRig is not parented to the player, update its global_position here.)
	
	match state:
		CameraState.FREE:
			_process_free_mode(delta)
		CameraState.LOCK_ON:
			_process_lock_on_mode(delta)
	_update_camera_position()
	
func _process_free_mode(delta: float) -> void:
	# In free mode, the camera is controlled by the mouse (or gamepad right stick).
	# You can change these input methods as needed.
	var input_rot = Vector2.ZERO
	input_rot.x = Input.get_action_strength("pan_right") - Input.get_action_strength("pan_left")
	input_rot.y = Input.get_action_strength("pan_up") - Input.get_action_strength("pan_down")
	
	# Rotate the pivot horizontally.
	pivot.rotate_y(-input_rot.x * free_sensitivity * delta)
	
	# Adjust vertical rotation on the arm (pitch).
	var new_pitch = arm.rotation_degrees.x - input_rot.y * free_sensitivity * delta * vertical_speed
	arm.rotation_degrees.x = clamp(new_pitch, vertical_clamp_min, vertical_clamp_max)
	
func _process_lock_on_mode(delta: float) -> void:
	# In lock-on mode, we assume lock_target is valid.
	if lock_target:
		# Calculate direction from pivot (player) to target on the horizontal plane.
		var target_dir: Vector3 = lock_target.global_transform.origin - pivot.global_transform.origin
		target_dir.y = 0
		if target_dir.length() > 0:
			target_dir = target_dir.normalized()
			# Compute desired yaw.
			var desired_yaw = atan2(target_dir.x, target_dir.z)
			# Smoothly rotate the pivot to face the target.
			pivot.rotation.y = lerp_angle(pivot.rotation.y, desired_yaw, rotation_speed * delta)
	
	# Allow manual vertical adjustment even in lock-on.
	var input_vertical = Input.get_action_strength("pan_up") - Input.get_action_strength("pan_down")
	var new_pitch = arm.rotation_degrees.x - input_vertical * free_sensitivity * delta * vertical_speed
	arm.rotation_degrees.x = clamp(new_pitch, vertical_clamp_min, vertical_clamp_max)
	
func _update_camera_position() -> void:
	# Always place the camera at a fixed offset along the arm’s local -Z axis.
	arm.position = Vector3(1, 0, -target_distance)

# --- Public API for switching modes ---
func set_lock_on_target(target: Node3D) -> void:
	lock_target = target
	state = CameraState.LOCK_ON

func clear_lock_on() -> void:
	lock_target = null
	state = CameraState.FREE
