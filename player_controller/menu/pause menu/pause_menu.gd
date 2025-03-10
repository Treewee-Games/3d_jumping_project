extends Control

@onready var equipment_screen: Control = $PauseUI/EquipmentScreen
@onready var inventory_screen: Control = $PauseUI/InventoryScreen
@onready var map_screen: Control = $PauseUI/MapScreen
@onready var save_screen: Control = $PauseUI/SaveScreen
@onready var sword_slot: Label = $PauseUI/EquipmentScreen/SwordSlot
@onready var boots_slot: Label = $PauseUI/EquipmentScreen/BootsSlot
@onready var shield_slot: Label = $PauseUI/EquipmentScreen/ShieldSlot

var is_paused := false

func _ready() -> void:
	update_equipment_ui()
		
func toggle_pause_menu()->void:
	is_paused = !is_paused
	get_tree().paused = is_paused #Pauses the game
	visible = is_paused #Shows or hides the menu
	
	if is_paused:
		show_tab("Equipment") #Default to Equipment Tab when opened
		
func show_tab(tab_name: String)->void:
	equipment_screen.visible = (tab_name == "Equipment")
	inventory_screen.visible = (tab_name == "Inventory")
	map_screen.visible = (tab_name == "Map")
	save_screen.visible = (tab_name == "Save")

func update_equipment_ui()-> void:
	sword_slot.text = GlobalStats.equipment["swords"]
	shield_slot.text = GlobalStats.equipment["shields"]
	boots_slot.text = GlobalStats.equipment["boots"]
	
func _on_sword_slot_pressed()->void:
	cycle_equipment("swords", "swords")
	
func _on_shield_slot_pressed()->void:
	cycle_equipment("shields", "shields")
	
func _on_boots_slot_pressed()->void:
	cycle_equipment("boots", "boots")
	
func cycle_equipment(slot_type: String, slot_name: String)->void:
	if slot_type in GlobalStats.inventory and slot_name in GlobalStats.equipment:
		var inventory_list = GlobalStats.inventory[slot_type]
		var current_item = GlobalStats.equipment[slot_name]
		var next_item_index = (inventory_list.find(current_item) +1) % inventory_list.size()
		
		GlobalStats.equip_item(slot_name, inventory_list[next_item_index])
		update_equipment_ui()
