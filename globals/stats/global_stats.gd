extends Node

#playerstats
var player_health := 4
var soul_count : int
var key_count : int
var boss_key_count : int
var powers : Dictionary = {"Light Power": false,}
#enemythings
var enemy_health : float

#itemsprobably


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

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
