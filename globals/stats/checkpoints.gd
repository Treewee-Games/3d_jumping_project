extends Node
#Checkpoint scripting


#This variable stores the last valid checkpoint position.
var checkpoint_position: Vector3 = Vector3.ZERO
#This variable will store a scene path or checkpoint names
var checkpoint_scene: String = ""

func set_checkpoint(new_position: Vector3)->void:
	checkpoint_position = new_position
	print("Checkpoint set to :", checkpoint_position)
	
func get_checkpoint()-> Vector3:
	return checkpoint_position
