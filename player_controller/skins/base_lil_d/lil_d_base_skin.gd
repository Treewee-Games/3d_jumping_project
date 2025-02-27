extends Node3D

@onready var move_state_machine = $AnimationTree.get("parameters/move_state_machine/playback")
@onready var animPlayer_speed = $AnimationPlayer.speed_scale

func set_move_state(state_name: String)-> void:
	move_state_machine.travel(state_name)

func set_anim_speed(value: float)-> void:
	animPlayer_speed = value
	
