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
var targeting: bool = false
var enemy_stats: Dictionary = {}
var health: float = 0
var damage: float = 0
var speed: float = 0
@export var lock_on_distance: float = 7.0



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
		speed = -2
		apply_knockback(25)
		health -= 1
		await get_tree().create_timer(.4).timeout
		speed = enemy_stats["speed"]
		hit = false
		targeting = false

func setup_enemy(_enemy_name:String)->void:
	#Getting the base data from GlobalStats
	enemy_stats = GlobalStats.get_enemy_data(creature_name).duplicate()
	health = enemy_stats["health"]
	damage = enemy_stats["damage"]
	speed = enemy_stats["speed"]
	
func _process(delta: float) -> void:
	if not is_dead:
		var distance = global_transform.origin.distance_to(player.global_transform.origin)
		state_timer += delta
		health_processing()
		trans_states(delta)
		move_and_slide()
		creature_skin.attack()
		if distance > lock_on_distance:
			targeting = false
		else:
			targeting = true

func health_processing()->void:
	clamp(health, 0, enemy_stats["health"])
	if health <= 0:
		creature_skin.play_death()
		is_dead = true
		await get_tree().create_timer(1.4).timeout
		self.queue_free()

func trans_states(_delta)->void:
	if state == creature_skin.all_states["State"][0]:
		if state_timer >= 2.0 and not targeting:
			creature_skin.state_rules(1)
			state = creature_skin.current_state
		if targeting:
			creature_skin.state_rules(2)
			state = creature_skin.current_state
	elif state == creature_skin.all_states["State"][1]:
		if state_timer >= 7.0 and not targeting:
			creature_skin.state_rules(2)
			state = creature_skin.current_state 
			state_timer = 0.0
		if targeting:
			creature_skin.state_rules(2)
			state = creature_skin.current_state
	elif state == creature_skin.all_states["State"][2]:
		if state_timer >= 10.0 and not targeting:
			creature_skin.state_rules(0)
			state = creature_skin.current_state 
			state_timer = 0.0
			velocity = Vector3.ZERO

func apply_knockback(knockback_strength: float = 2.0) -> void:
	# Calculate the vector from the player to the enemy.
	var knockback_direction: Vector3 = (global_transform.origin - player.global_transform.origin).normalized()
	
	# Optionally add a vertical component if you want a slight upward knockback.
	knockback_direction.y = 0.2  # Adjust this value as needed.
	knockback_direction = knockback_direction.normalized()
	
	# Apply the knockback force to the enemy's velocity.
	velocity += knockback_direction * knockback_strength
