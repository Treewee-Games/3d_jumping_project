extends Control

const data : Dictionary = {	
	'powers': {
		'index': 0,
	},
	'inventory': {
		'index': 1,
	},
	'map': {
		'index': 2,
	}
}
@onready var item_scene: PackedScene = preload("res://player_controller/menu/pause menu/item_slot.tscn")
@onready var power_container: GridContainer = $VBoxContainer/MarginContainer/Tabs/Powers
@onready var inventory: GridContainer = $VBoxContainer/MarginContainer/Tabs/Inventory/Items
@onready var map: TextureRect = $VBoxContainer/MarginContainer/Tabs/Map
@onready var menu_wait: Timer = $menu_wait
@export var hud : Control
var is_paused : bool = false
var selection_index: int

func _ready() -> void:
	update_pause_menu()
	GlobalStats.power_unlocked.connect(update_pause_menu)
	GlobalStats.equipment_unlocked.connect(update_pause_menu)
	focus_item()

func _input(_event: InputEvent) -> void:
	var menu_dir = int(Input.get_axis("menu_left", "menu_right"))
	if menu_dir and not menu_wait.time_left:
		menu_wait.start()
		selection_index = posmod(selection_index + menu_dir, 3)
		$VBoxContainer/MarginContainer/Tabs.current_tab = selection_index
		focus_item()
	
func focus_item()->void:
	await get_tree().create_timer(.1).timeout
	if selection_index == data["powers"]["index"]:
		if power_container.get_child_count() == 0:
			return
		power_container.get_child(0).grab_focus()
	
	elif selection_index == data["inventory"]["index"]:
		if inventory.get_child_count() == 0:
			return
		inventory.get_child(0).grab_focus()

func create_power_button()->void:
	for child in power_container.get_children():
		child.queue_free()
		
	for power in GlobalStats.powers.keys():
		if GlobalStats.powers[power]:
			var power_button = item_scene.instantiate()
			power_button.setup(power, GlobalStats.power_list.find(power))
			power_button.size_flags_horizontal = Control.SIZE_EXPAND | Control.SIZE_FILL
			power_container.add_child(power_button)
			power_container.get_child(0).grab_focus()
			power_button.ability_selected.connect(hud.update_abilities)
			await get_tree().create_timer(0.1).timeout

func create_inventory_button()->void:
	for child in inventory.get_children():
		child.queue_free()
	
	for equipment in GlobalStats.equipables.keys():
		if GlobalStats.equipables[equipment]:
			var inventory_button = item_scene.instantiate()
			inventory_button.setup(equipment, GlobalStats.inventory.find(equipment))
			inventory_button.size_flags_horizontal = Control.SIZE_EXPAND | Control.SIZE_FILL
			inventory.add_child(inventory_button)
			inventory.get_child(0).grab_focus()
			
			await get_tree().create_timer(0.1).timeout
			
func update_pause_menu()->void:
	create_power_button()
	create_inventory_button()
	await get_tree().create_timer(0.1).timeout
	focus_item()
	
func toggle_pause()->void:
	if is_paused == false:
		is_paused = true
		focus_item()
	else:
		is_paused = false
