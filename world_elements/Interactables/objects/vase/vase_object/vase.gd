extends RigidBody3D
@onready var break_vase: Node3D = $break_vase

func _ready() -> void:
	break_vase.connect("destroy_self", Callable(self, "free"), CONNECT_DEFERRED)
	
func free()->void:
	self.queue_free()
