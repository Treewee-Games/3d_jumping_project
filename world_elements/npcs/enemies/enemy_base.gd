extends "res://world_elements/npcs/npc.gd"
var hit : bool = false
var state_timer: float = 0.0
@onready var player = get_tree().get_first_node_in_group("player") as CharacterBody3D
@onready var hit_area: Area3D = $Area3D
@onready var target_indicator: MeshInstance3D = $target/MeshInstance3D
@onready var creature_skin = get_node(creature_name)
@export var creature_name: String = "Slime"
@onready var state: String = creature_skin.current_state
var is_dead: bool = false
var enemy_stats: Dictionary = {}
var health: float = 0
var damage: float = 0
var speed: float = 0
var velocity: Vector3 = Vector3.ZERO



func _ready() -> void:
	hit_area.connect("trigger_hit",Callable(self, "reaction"),CONNECT_DEFERRED)
	target.hide()
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(target, "position", Vector3(0, 1, 0), .4)
	tween.tween_property(target, "position", Vector3(0, .7, 0), .4)
	setup_enemy(creature_name)
	
func reaction()->void:
	if not hit and not is_dead:
		hit = true
		creature_skin.got_hit()
		tweening(creature_skin, 0.2)
		health -= 1
		await get_tree().create_timer(.4).timeout
		hit = false

func setup_enemy(_enemy_name:String)->void:
	#Getting the base data from GlobalStats
	enemy_stats = GlobalStats.get_enemy_data(creature_name).duplicate()
	health = enemy_stats["health"]
	damage = enemy_stats["damage"]
	speed = enemy_stats["speed"]
	

func _process(delta: float) -> void:
	if not is_dead:
		state_timer += delta
		health_processing()
		trans_states()
		move_towards_player(delta)


func health_processing()->void:
	clamp(health, 0, enemy_stats["health"])
	if health <= 0:
		creature_skin.play_death()
		is_dead = true
		await get_tree().create_timer(1.4).timeout
		self.queue_free()


func trans_states()->void:
	if state == creature_skin.all_states["State"][0]:
		if state_timer >= 2.0:
			creature_skin.state_rules(1)
			state = creature_skin.current_state
	elif state == creature_skin.all_states["State"][1]:
		if state_timer >= 7.0:
			creature_skin.state_rules(0)
			state = creature_skin.current_state 
			state_timer = 0.0

func move_towards_player(delta: float)-> void:
	if player == null:
		return
	var enemy_pos: Vector3 = global_transform.origin
	var player_pos: Vector3 = player.global_transform.origin
	var to_player: Vector3 = player_pos - enemy_pos
	to_player.y = 0
	
	if to_player.length() >0:
		to_player = to_player.normalized()
		look_at(-player_pos, Vector3.UP)
		velocity += to_player * speed
		print(to_player)
