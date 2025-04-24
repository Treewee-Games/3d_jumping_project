extends Control

@onready var health := $VSplitContainer/HBoxContainer/Health
var health_scene: PackedScene = preload("res://player_controller/menu/HUD/health.tscn")
var current_max_health: int = 0
var current_health: int = 0
@onready var abil_1: TextureRect = $VSplitContainer/HBoxContainer/VBoxContainer/HBoxContainer/abil_1
@onready var abil_2: TextureRect = $VSplitContainer/HBoxContainer/VBoxContainer/VBoxContainer2/abil_2
@onready var abil_3: TextureRect = $VSplitContainer/HBoxContainer/VBoxContainer/HBoxContainer/abil_3
@onready var abil_4: TextureRect = $VSplitContainer/HBoxContainer/VBoxContainer/VBoxContainer3/abil_4
@onready var soulcount: Label = $VSplitContainer/Bottom_Layer/VBoxContainer/HBoxContainer/Soulcount
@onready var key_count: Label = $VSplitContainer/Bottom_Layer/VBoxContainer/HBoxContainer2/KeyCount

var assigned_abilities: Dictionary = {
	0: "None", #Slot 1
	1: "None", #Slot 2
	2: "None", #Slot 3
	3: "None", #Slot 4
}

var ability_slots: Array
func _ready() -> void:
	ability_slots = [abil_1, abil_2, abil_3, abil_4]
	soulcount.text = str(GlobalStats.soul_count)
	key_count.text = str(GlobalStats.key_count)


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

func update_abilities(current_texture: Texture, slot_index: int, power_name: String)->void:
	if slot_index < ability_slots.size():
		ability_slots[slot_index].texture = current_texture
		assigned_abilities[slot_index] = power_name
func get_assigned_power(slot_index: int)-> String:
	if null:
		"None"
	return assigned_abilities.get(slot_index, "None") # Return "None" if now power is assigned
	
func activate_power(slot_index: int)->void:
	var power_name = get_assigned_power(slot_index)
	if power_name and power_name != "None":
		print("Activating Power:", power_name)
		GlobalStats.use_power(power_name)
	else:
		print("No power assigned to slot", slot_index)
func update_soul(value: int)->void:
	soulcount.text = str(value)
	
func update_keys(value: int)->void:
	key_count.text = str(value)
