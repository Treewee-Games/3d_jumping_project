extends Node
#region player stats
#playerstats
var player_max_health := 3
var player_health := 3
var soul_count : int
var key_count : int
var boss_key_count : int
var powers : Dictionary = {"Light Power": false, 
"Claws": false,
"Placeholder1": false,
"Placeholder2": false,
"Placeholder3": false,
"Placeholder4": false,
"Placeholder5": false,
"Placeholder6": false,
"Placeholder7": false,
"Placeholder8": false,
"Placeholder9": false,
"Placeholder10": false,
"Placeholder11": false,
"Placeholder12": false,
"Placeholder13": false,
"Placeholder14": false,
"Placeholder15": false,
}
var inventory : Array = []

var equipment : Dictionary= {"Equipment1": null, #Slot 1
				"Equipment2": null, #Slot 2
				"Equipment3": null, #Slot 3
				}
#endregion
#region enemy things
#enemythings
var enemy_health : float
#endregion
#items in the world probably


# Called when the node enters the scene tree for the first time.


#region Power unlocks
#function used to unlock powers
func unlock_powers(power_name: String):
	if powers.has(power_name) and not powers[power_name]:
		powers[power_name]= true
		inventory.append(power_name)
		print(power_name + "unlocked!")
	else:
		print("Power does not exist or is already unlocked" + power_name)
		
#function used to check power is available
func has_power(power_name: String)->bool:
	return powers.get(power_name, false)
#endregion

#region Equpiment/Inventory
func equip_power(slot: String, power_name: String):
	if power_name in inventory and slot in equipment:
		equipment[slot] = power_name
		print("Equipped:", slot, "->", power_name)
	else:
		print("Error: Cannot equp power", power_name, "to slot", slot)
#endregion
