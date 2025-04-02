extends Node3D
@onready var blood: GPUParticles3D = $GPUParticles3D
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var move_state_machine = $AnimationTree.get("parameters/move_state_machine/playback")
@onready var skele: Skeleton3D = $MonsterArmature/Skeleton3D
@onready var defeat_smoke: GPUParticles3D = $DefeatSmoke
var current_state: String = "Idle"
var all_states: Dictionary = {"State":["Idle", "Dance", "Walk", "Strike"]}
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func got_hit()->void:
	$AnimationTree.set("parameters/Got_hit/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	GlobalStats.hit_stop(0.01)
	blood.emitting = true
	
	
func play_death()->void:
	$AnimationTree.set("parameters/Death/active",AnimationNodeOneShot.CONNECT_PERSIST)
	$AnimationTree.set("parameters/Death/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


func defeat(value: bool)->void:
	defeat_smoke.emitting = value

func set_move_state(state: String)-> void:
	move_state_machine.travel(state)
	
func return_current_state(state: String)->void:
	current_state = state

func state_rules(set_index_value: int = 0)->void:
	if current_state == "Idle":
		var index: int = set_index_value
		var state_name: String = all_states["State"][index]
		match state_name:
			"Idle":
				set_move_state(state_name)
			"Dance":
				set_move_state(state_name)
				return_current_state(state_name)
				print("Idle to Dance")
			"Walk":
				set_move_state(state_name)
	if current_state == "Dance":
		var index: int = set_index_value
		var state_name: String = all_states["State"][index]
		match state_name:
			"Idle":
				set_move_state(state_name)
				return_current_state(state_name)
				print("Dance to Idle")
			"Dance":
				set_move_state(state_name)
			"Walk":
				set_move_state(state_name)
	if current_state == "Walk":
		var index: int = set_index_value
		var state_name: String = all_states["State"][index]
		match state_name:
			"Idle":
				set_move_state(state_name)
			"Dance":
				set_move_state(state_name)
			"Walk":
				set_move_state(state_name)
