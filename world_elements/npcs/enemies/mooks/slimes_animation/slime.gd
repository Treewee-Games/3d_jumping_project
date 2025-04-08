extends Node3D
@onready var blood: GPUParticles3D = $GPUParticles3D
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var move_state_machine = $AnimationTree.get("parameters/move_state_machine/playback")
@onready var skele: Skeleton3D = $MonsterArmature/Skeleton3D
@onready var defeat_smoke: GPUParticles3D = $DefeatSmoke
var current_state: String = "Idle"
var all_states: Dictionary = {"State":["Idle", "Dance", "Walk"]}
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var player = get_tree().get_first_node_in_group("player") as CharacterBody3D
@export var random_change_interval: float = 6.0
var random_direction: Vector3 = Vector3.ZERO
var random_timer: float = 0
@export var base : CharacterBody3D
@onready var player_finder: RayCast3D = $Player_finder
var is_hit: bool = false
var attacked: bool = false


func _ready() -> void:
	randomize()
	random_direction = generate_random_direction()
	random_timer = random_change_interval

func got_hit()->void:
	is_hit = true
	$AnimationTree.set("parameters/Got_hit/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	GlobalStats.hit_stop(0.015)
	blood.emitting = true
	await $AnimationTree.animation_finished
	is_hit = false
	
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
	var index: int = set_index_value
	var state_name: String = all_states["State"][index]
	set_move_state(state_name)
	return_current_state(state_name)

func move_towards_player(_delta: float)-> void:
	if player == null:
		return
	var enemy_pos: Vector3 = global_transform.origin
	var player_pos: Vector3 = player.global_transform.origin
	var to_player: Vector3 = player_pos - enemy_pos
	to_player.y = 0
	
	if to_player.length() >0:
		to_player = to_player.normalized()
		player_pos.y = global_transform.origin.y
		var current_yaw = rotation.y
		var desired_yaw: float = atan2(to_player.x, to_player.z)
		rotation.y = lerp_angle(current_yaw, desired_yaw, 0.2)
		#look_at(player_pos, Vector3.UP, true)
		base.velocity = to_player * base.speed
		
func generate_random_direction()->Vector3:
	var random_angle = randf_range(0.0, TAU)
	return Vector3(sin(random_angle), 0, cos(random_angle)).normalized()

func move_rand(delta: float)->void:
	random_timer -= delta
	
	if random_timer <= 0:
		random_direction = generate_random_direction()
		random_timer = random_change_interval
		
		
	base.velocity = random_direction * base.speed
	
	if base.velocity.length() > 0:
		var current_yaw = rotation.y
		var desired_yaw = atan2(random_direction.x, random_direction.z)
		rotation.y = lerp_angle(current_yaw, desired_yaw, 0.2)
		
		#look_at(global_transform.origin + random_direction,Vector3.UP,true)

	if base.targeting:
		move_towards_player(delta)

func movement(delta)->void:
	if base.targeting:
		if not attacked:
			if not is_hit:
				move_towards_player(delta)
	else:
		if not attacked:
			if not is_hit:
				move_rand(delta)

func _physics_process(delta: float) -> void:
	if current_state == "Walk":
		movement(delta)

func attack()->void:
	var collider = player_finder.get_collider()
	if collider == null:
		return
	if collider.is_in_group("player"):
		if not attacked:
			play_attack()

func _on_attack_area_body_entered(body: Node3D) -> void:
	if body == player:
		if player.has_method("damaged"):
			player.damaged(base)

func play_attack()->void:
	if not is_hit:
		attacked = true
		base.velocity = Vector3.ZERO
		$AnimationTree.set("parameters/AttackShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		await $AnimationTree.animation_finished
		await get_tree().create_timer(1).timeout
		attacked = false
