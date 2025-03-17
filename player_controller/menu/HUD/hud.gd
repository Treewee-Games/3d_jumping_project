extends Control

@onready var health := $VSplitContainer/HBoxContainer/Health
var health_scene: PackedScene = preload("res://player_controller/menu/HUD/health.tscn")
var current_max_health: int = 0
var current_health: int = 0

func setup(max_health_value: int, current_health_value: int) -> void:
	current_max_health = max_health_value
	current_health = current_health_value
	
	for i in range(max_health_value):
		var heart = health_scene.instantiate()
		health.add_child(heart)
		
	update_health(current_health_value, false)

func update_health(value: int, heal_all: bool = false) -> void:
	if value < 0 or value > current_max_health:
		print("Invalid health value")
		return
	
	current_health = value
	
	for i in range(current_max_health):
		var heart = health.get_child(i)
		if heart:
			if heal_all or i < value:
				heart.add_health(true)
			else:
				heart.add_health(false)

func max_health(value: int) -> void:
	if value < 0:
		print("Invalid max health value")
		return
	
	if value > current_max_health:
		for i in range(current_max_health, value):
			var heart = health_scene.instantiate()
			health.add_child(heart)
	elif value < current_max_health:
		for i in range(current_max_health - value):
			var last_heart = health.get_child(health.get_child_count() - 1)
			if last_heart:
				last_heart.queue_free()
		
	current_max_health = value
		
	update_health(current_health, true)
