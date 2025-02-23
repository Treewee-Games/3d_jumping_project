extends Node

enum States {IDLE, MOVING, JUMPING, CROUCHING}

var current_state = States.IDLE
var crouching := false
@export var player : CharacterBody3D

func _process(_delta: float) -> void:
	match current_state:
		States.IDLE:
			state_idle()
		States.MOVING:
			state_moving()
		States.JUMPING:
			state_jumping()
		States.CROUCHING:
			state_crouching()
			
func change_state(new_state):
	if current_state != new_state:
		exit_state(current_state)
		current_state = new_state
		enter_state(new_state)

func enter_state(state):
	match state:
		States.IDLE:
			pass
		States.MOVING:
			pass
		States.JUMPING:
			pass
		States.CROUCHING:
			crouch_player()

func exit_state(state):
	if state == States.CROUCHING:
		stand_up_player()

func state_idle():
	if player.movement_input != Vector2.ZERO:
		change_state(States.MOVING)
	elif Input.is_action_just_pressed("ui_accept"):
		change_state(States.JUMPING)
	elif Input.is_action_pressed("crouch"):
		change_state(States.CROUCHING)
	#print("idle?")
	
func state_moving():
	if player.movement_input == Vector2.ZERO:
		change_state(States.IDLE)
	elif Input.is_action_just_pressed("ui_accept"):
		change_state(States.JUMPING)
	#print("moving?")	
	
func state_jumping():
	if player.is_on_floor():
		change_state(States.IDLE)
	#print("jumping?")
	
func state_crouching():
	if not Input.is_action_pressed("crouch") and not player.ceiling_check:
		change_state(States.IDLE)
	#print("crouching?")
	
func crouch_player():
	if crouching:
		return
	
	var tween = player.create_tween()
	tween.tween_property(player.mesh, "position", Vector3(0,-.5,0),.01).set_ease(Tween.EASE_IN)
	tween.tween_property(player.collision_mesh, "position", Vector3(0,-.5,0),.01).set_ease(Tween.EASE_IN)
	tween.tween_property(player.mesh, "scale", Vector3(1,.5,1),.1).set_ease(Tween.EASE_IN)
	tween.tween_property(player.collision_mesh, "scale", Vector3(1,.5,1),.1).set_ease(Tween.EASE_IN)
	
	crouching = true
func stand_up_player():
	if not player.ceiling_check:
		
		var tween = player.create_tween()
		tween.tween_property(player.mesh, "position", Vector3(0,0,0),.01).set_ease(Tween.EASE_OUT)
		tween.tween_property(player.collision_mesh, "position", Vector3(0,0,0),.01).set_ease(Tween.EASE_OUT)
		tween.tween_property(player.mesh, "scale", Vector3(1,1,1),.1).set_ease(Tween.EASE_OUT)
		tween.tween_property(player.collision_mesh, "scale", Vector3(1,1,1),.1).set_ease(Tween.EASE_OUT)
		
		crouching = false
