extends Node3D
@onready var hit_area: Area3D = $Area3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer2
var destroyed : bool = false
@onready var soul : PackedScene = load("res://world_elements/collectibles/currencies/soul.tscn")
signal destroy_self


func _ready() -> void:
	hit_area.connect("trigger_hit",Callable(self, "play_reaction"),CONNECT_DEFERRED)
func play_reaction()->void:
	if not destroyed:
		animation_player.play("vase_break")
		hit_area.disconnect("trigger_hit", Callable(self, "play_reaction"))
		var max_souls := 5
		var soul_count := randi_range(0, randi_range(0, max_souls))
		
		for i in soul_count:
			var s = soul.instantiate()
			var offset = Vector3(randf_range(-0.5, 0.5), 0.2, randf_range(-0.5,0.5))
			get_tree().current_scene.add_child(s)
			s.global_position = global_position + offset

		
	
		print("???? what are we doing here????")
		await get_tree().create_timer(1).timeout
		destroyed = true
		destroy_self.emit()
