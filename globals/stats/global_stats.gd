extends Node
#region player stats
#playerstats
var player_health := 4
var soul_count : int
var key_count : int
var boss_key_count : int
var powers : Dictionary = {"Light Power": false, "Claws": false}
var equipment : Dictionary= {"swords": "Basic Sword",
				"shields": "Wooden Shield",
				"boots": "Normal Boots",
				}
var inventory : Dictionary= {"swords": ["Basic Sword", "Master Sword"],
				"shields": ["Wooden Shield", "Hylian Shield"],
				"boots": ["Normal Boots", "Hover Boots"]
				}
#endregion
#region enemy things
#enemythings
var enemy_health : float
#endregion
#items in the world probably


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(inventory)
	if "swords" in inventory:
		print("okay dumbass")
	else:
		print("Error")


#region Power unlocks
#function used to unlock powers
func unlock_powers(power_name: String):
	if powers.has(power_name):
		powers[power_name]= true
		print(power_name + "unlocked!")
	else:
		print("Power does not exist" + power_name)
		
#function used to check power is available
func has_power(power_name: String)->bool:
	return powers.get(power_name, false)
#endregion

#region Equpiment/Inventory
func equip_item(slot: String, item_name: String):
	if item_name in inventory[slot]:
		equipment[slot] = item_name
		print("Equipped:", slot, "->", item_name)
