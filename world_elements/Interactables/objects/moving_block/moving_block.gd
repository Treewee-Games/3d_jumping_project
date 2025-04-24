extends RigidBody3D
# Adjustable parameters:
@export var default_offset: float = 3.0   # default distance in front of the player
@export var min_offset: float = 1.0       # minimum allowed offset
@export var max_offset: float = 5.0       # maximum allowed offset
@export var adjust_speed: float = 2.0     # how quickly the block moves forward/back when adjusting

var attached: bool = false
var attached_player: Node3D = null


# Call this to attach the block to the player.
func start_push(player_node: Node3D) -> void:
	attached = true
	attached_player = player_node
	print(attached_player)

# Call this to detach the block from the player.
func stop_push(player_node: Node3D) -> void:
	attached = false
	if attached_player == player_node:
		attached_player = null
	# Re-enable physics if desired.

func _physics_process(_delta: float) -> void:
	if attached and attached_player:
		# Get the player's forward direction.
		# (Assuming that the player's "forward" is negative Z, which is common in Godot.)
		var player_raise: Vector3 = attached_player.global_transform.origin
		player_raise.y += .6
		var player_forward: Vector3 = attached_player.global_transform.basis.x.normalized()
		
		# Set the block's global position to be in front of the player at the given offset.
		global_transform.origin = player_raise + player_forward
		
		# Lock the block's rotation to the player's so the block stays aligned.
		global_transform.basis = attached_player.global_transform.basis
	else:
		# When not attached, you can run any other block-specific movement or physics.
		pass
