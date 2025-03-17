extends Control
@onready var container: TextureRect = $Container
@onready var life: TextureRect = $Life
var fades : bool

func _ready() -> void:
	var tween = create_tween()
	tween.tween_property(self, "custom_minimum_size", Vector2(100, 100), .1)


func _process(delta: float) -> void:
	animate_health()

func add_health(value: bool)->void:
	fades = value
	
	
func animate_health()->void:
	var tween = create_tween()
	if fades:
		tween.tween_property(life, "modulate:a", 1, .3)
	if not fades:
		tween.tween_property(life, "modulate:a", 0, .3)
