extends Node3D
@onready var hit_area: Area3D = $Area3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var rigid_body_3d: RigidBody3D = $RigidBody3D


func _ready() -> void:
	hit_area.connect("trigger_hit",Callable(self, "play_reaction"))
	
func play_reaction()->void:
	animation_player.play("breaking_1")
	rigid_body_3d.queue_free()
	hit_area.disconnect("trigger_hit", Callable(self, "play_reaction"))
