extends RigidBody3D

@export var speed = 10

@onready var camera : ThirdPersonCamera = $ThirdPersonCamera


func _physics_process(_delta):
	if Input.is_action_pressed("pan_up") :
		var dir = camera.get_front_direction()
		apply_central_force(dir * speed)
	if Input.is_action_pressed("pan_down") :
		var dir = camera.get_back_direction()
		apply_central_force(dir * speed)
	if Input.is_action_pressed("pan_left") :
		var dir = camera.get_left_direction()
		apply_central_force(dir * speed)
	if Input.is_action_pressed("pan_right") :
		var dir = camera.get_right_direction()
		apply_central_force(dir * speed)
	if Input.is_action_just_pressed("camera_shake") :
		camera.apply_preset_shake(0)


func _unhandled_input(event):
	if event.is_action_pressed("ui_accept") :
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED :
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			camera.follow_target = camera.FOLLOW_TARGETS.NONE
		else :
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			camera.follow_target = camera.FOLLOW_TARGETS.MOUSE
