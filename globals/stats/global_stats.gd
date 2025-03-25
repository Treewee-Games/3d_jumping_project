extends Node
#region player stats
#playerstats
var player_max_health := 3
var player_health := 3
var soul_count : int
var key_count : int
var boss_key_count : int
#region powers
signal power_unlocked
signal activate_power(power_name:String)
var powers : Dictionary = {"Light Power": false, 
"Placeholder": false,
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
var power_list : Array = []
#endregion

#region equipment/inventory
signal equipment_unlocked
var equipables : Dictionary = {"Claws": false,
"Placeholder": false,
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
var melee_item

#endregion
#endregion
#region enemy things
#enemythings
var enemy_health : float
#endregion
#items in the world probably


# Called when the node enters the scene tree for the first time.


#region Power unlocks/Usages
#function used to unlock powers
func unlock_powers(power_name: String)->void:
	if powers.has(power_name) and not powers[power_name]:
		powers[power_name]= true
		power_list.append(power_name)
		power_unlocked.emit()
	else:
		print("Power does not exist or is already unlocked" + power_name)
		
#function used to check power is available
func has_power(power_name: String)->bool:
	return powers.get(power_name, false)
	
func use_power(power_name: String)->void:
	activate_power.emit(power_name)
#endregion

#region Equpiment/Inventory
func unlock_equipables(equipment_name: String)->void:
	if equipables.has(equipment_name) and not equipables[equipment_name]:
		equipables[equipment_name] = true
		inventory.append(equipment_name)
		equipment_unlocked.emit()
	else:
		print("Inventory item already added or does not exist" + equipment_name)
		
func has_equipment(equipment_name: String)-> bool:
	return equipables.get(equipment_name, false)

func is_equipped(equipped_item: Dictionary)-> void:
	melee_item = equipped_item
#endregion
