extends Node

enum States {IDLE, MOVING, JUMPING, FALLING, CROUCHING, CLIMBING}

var current_state = States.IDLE
var crouching := false
@export var player : CharacterBody3D
@onready var skin: Node3D = $"../lil_skin" #if this doesn't work, it's cause the node tree moved.

var state_names = {
	States.IDLE: "IDLE",
	States.MOVING: "MOVING",
	States.JUMPING: "JUMPING",
	States.FALLING: "FALLING",
	States.CROUCHING: "CROUCHING",
	States.CLIMBING: "CLIMBING",
}

func _process(_delta: float) -> void:
	#print("Current State:", state_names[current_state])
	match current_state:
		States.IDLE:
			state_idle()
		States.MOVING:
			state_moving()
		States.JUMPING:
			state_jumping()
		States.FALLING:
			state_falling()
		States.CROUCHING:
			state_crouching()
		States.CLIMBING:
			state_climbing()
			
func change_state(new_state):
	if current_state != new_state:
		exit_state(current_state)
		current_state = new_state
		enter_state(new_state)

func enter_state(state):
	match state:
		States.IDLE:
			skin.set_move_state("idle")
		States.MOVING:
			skin.set_move_state("walk")
		States.JUMPING:
			skin.set_move_state("jump")
		States.FALLING:
			pass
		States.CROUCHING:
			crouch_player()
		States.CLIMBING:
			pass

func exit_state(state):
	if state == States.CROUCHING:
		stand_up_player()

func state_idle():
	if player.is_climbing:
		change_state(States.CLIMBING)
	if player.falling:
		change_state(States.FALLING)
	elif player.is_airborne:
		change_state(States.JUMPING)
	elif player.movement_input != Vector2.ZERO and player.is_on_floor():
		change_state(States.MOVING)
	elif Input.is_action_pressed("crouch"):
		change_state(States.CROUCHING)
	#print("idle?")
	
func state_moving():
	if player.is_climbing:
		change_state(States.CLIMBING)
	elif player.falling:
		change_state(States.FALLING)
	if player.movement_input == Vector2.ZERO and player.is_on_floor():
		change_state(States.IDLE)
	elif player.is_airborne:
		change_state(States.JUMPING)
	#print("moving?")	
	
func state_jumping():
	if player.is_climbing:
		change_state(States.CLIMBING)
	if player.falling:
		change_state(States.FALLING)
	elif player.is_on_floor():
		change_state(States.IDLE)
		
	#print("jumping?")

func state_falling():
	if player.is_climbing:
		change_state(States.CLIMBING)
	if player.is_on_floor():
		change_state(States.IDLE)

#region crouching
func state_crouching():
	if not player.movement_input.is_zero_approx():
		skin.set_move_state("crouch_crawl")
	elif Input.is_action_pressed("crouch"):
		skin.set_move_state("crouch")
	if not Input.is_action_pressed("crouch") and not player.ceiling_check:
		change_state(States.IDLE)
	#print("crouching?")
	
func crouch_player():
	if crouching:
		return
	skin.set_move_state("crouch")
	#var tween = player.create_tween()
	#tween.tween_property(player.mesh, "position", Vector3(0,-.5,0),.01).set_ease(Tween.EASE_IN)
	#tween.tween_property(player.collision_mesh, "position", Vector3(0,-.5,0),.01).set_ease(Tween.EASE_IN)
	#tween.tween_property(player.mesh, "scale", Vector3(1,.5,1),.1).set_ease(Tween.EASE_IN)
	#tween.tween_property(player.collision_mesh, "scale", Vector3(1,.5,1),.1).set_ease(Tween.EASE_IN)
	
	crouching = true
func stand_up_player():
	if not player.ceiling_check:
		skin.set_move_state("idle")
		#var tween = player.create_tween()
		#tween.tween_property(player.mesh, "position", Vector3(0,0,0),.01).set_ease(Tween.EASE_OUT)
		#tween.tween_property(player.collision_mesh, "position", Vector3(0,0,0),.01).set_ease(Tween.EASE_OUT)
		#tween.tween_property(player.mesh, "scale", Vector3(1,1,1),.1).set_ease(Tween.EASE_OUT)
		#tween.tween_property(player.collision_mesh, "scale", Vector3(1,1,1),.1).set_ease(Tween.EASE_OUT)
		
		crouching = false
#endregion

func state_climbing():
	if player.is_climbing:
		return
	else:
		if player.is_on_floor():
			change_state(States.IDLE)
		if player.is_airborne:
			change_state(States.JUMPING)
