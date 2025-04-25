extends Node3D
@onready var dialogue: Control = $Dialogue
@onready var player = get_tree().get_first_node_in_group("player") as CharacterBody3D
@onready var reading_cam: Camera3D = $Reading_Cam
@export_multiline var text_messages: String
var player_inside : bool = false




func _on_reading_area_body_entered(body: Node3D) -> void:
	if body == player:
		player_inside = true
		



func _on_reading_area_body_exited(body: Node3D) -> void:
	if body == player:
		player_inside = false		
func _process(_delta: float) -> void:
	if player_inside and Input.is_action_just_pressed("Use"):
		if dialogue.visible:
			dialogue.hide()
			player.emit_signal("pausing", false)
			var text_label: RichTextLabel = dialogue.get_child(0)
			reading_cam.clear_current()
			player.current_cam(true)
			text_label.visible_characters = 0
		else:
			player.emit_signal("pausing", true)
			dialogue.show()
			reading_cam.make_current()
			player.current_cam(false)
			dialogue.update_message(text_messages)
