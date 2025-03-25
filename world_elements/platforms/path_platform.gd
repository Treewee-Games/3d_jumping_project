extends "res://world_elements/platforms/platform.gd"

var player_on_platform: CharacterBody3D = null
var original_parent: Node3D = null
var is_on_platform: bool = false
@onready var detach_timer: Timer = $"Detach Timer"


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		if player_on_platform == null:
			if not is_on_platform:
				attach_player(body)


func _on_area_3d_body_exited(body: Node3D) -> void:
	if is_on_platform:
		if body == player:
			detach_timer.start()
		
func attach_player(player_p: CharacterBody3D)->void:
	if player_p.get_parent() == self:
		return
	is_on_platform = true
	original_parent = player_p.get_parent()
	player_p.reparent(self) #parents the player to the platform
	player_on_platform = player_p
	print("Player attached")
		
func detach_player()->void:
	if  player_on_platform:
		is_on_platform = false
		player_on_platform.reparent(original_parent)
		player_on_platform = null
		print("Player detached from platform")

func _physics_process(delta: float) -> void:
	if player_on_platform and player_on_platform.is_on_floor():
		if Input.is_action_just_pressed("ui_accept"):
			player.jumping(delta)
			detach_player()

func check_detach_condition()->void:
	if player_on_platform and not player_on_platform.is_on_floor():
		detach_player()

func _on_detach_timer_timeout() -> void:
	check_detach_condition()
