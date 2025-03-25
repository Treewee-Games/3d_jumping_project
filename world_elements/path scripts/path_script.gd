extends PathFollow3D

@export var speed : float
@export var button : bool = false

func _physics_process(delta: float) -> void:
	if not button:
		self.progress += speed * delta
	else:
		return
	
	


func _on_button_trigger_effect() -> void:
	button = false
