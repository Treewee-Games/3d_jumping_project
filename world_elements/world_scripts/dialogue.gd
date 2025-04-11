extends Control

@onready var rich_text_label: RichTextLabel = $RichTextLabel
@onready var timer: Timer = $Timer
@export var timing: float = .05

func _ready() -> void:
	await get_tree().create_timer(.5).timeout


func update_message(message: String)->void:
	rich_text_label.bbcode_enabled = true
	rich_text_label.text = message
	rich_text_label.visible_characters = 0
	timer.start(timing)

func _on_timer_timeout() -> void:
	if rich_text_label.visible_characters < rich_text_label.text.length():
		rich_text_label.visible_characters += 1
	else:
		timer.stop()
	
