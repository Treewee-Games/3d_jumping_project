extends Node3D

@onready var l_claws: Node3D = $Armature/Skeleton3D/l_equip/claws
@onready var r_claws: Node3D = $Armature/Skeleton3D/r_equip/claws
@onready var move_state_machine = $AnimationTree.get("parameters/move_state_machine/playback")
@onready var attack_state_machine = $AnimationTree.get("parameters/AttackStateMachine/playback")
@onready var animPlayer_speed = $AnimationPlayer.speed_scale
@onready var attacktimers: Timer = $Timer/attacktimers
var attacking := false



func set_move_state(state_name: String)-> void:
	move_state_machine.travel(state_name)

	
func attack()->void:
	if not attacking:
		if GlobalStats.has_power("Claws"):
			attack_state_machine.travel("attack2" if attacktimers.time_left else "attack")
			$AnimationTree.set("parameters/AttackOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
func is_attacking(value: bool)->void:
	attacking = value
