extends Button

@onready var texture_rect: TextureRect = $AspectRatioContainer/TextureRect
var type: String = "A power"
var equipment_index: int
var is_equipped: bool = false
signal ability_selected(current_texture: Texture, slot_index: int)

@warning_ignore("shadowed_variable_base_class")
func setup(name: String, index: int)->void:
	equipment_index = index
	type = name
	$AspectRatioContainer/TextureRect.texture = load("res://player_controller/menu/icon_textures/"+ name + ".png")
	



func _on_resized() -> void:
	custom_minimum_size.y = get_rect().size.x


func _input(_event: InputEvent) -> void:
	if has_focus() and equipment_index == 0:
		if Input.is_action_just_pressed("ability_1"):
			ability_selected.emit(texture_rect.texture,0, type)
		elif Input.is_action_just_pressed("ability_2"):
			ability_selected.emit(texture_rect.texture,1, type)
		elif Input.is_action_just_pressed("ability_3"):
			ability_selected.emit(texture_rect.texture,2, type)
		elif Input.is_action_just_pressed("ability_4"):
			ability_selected.emit(texture_rect.texture,3, type)


func _on_pressed() -> void:
	if GlobalStats.has_equipment(type):
		is_equipped = !is_equipped
		$Selector.visible = is_equipped
		var item_equipped = {type: is_equipped}
		GlobalStats.is_equipped(item_equipped)
		var item_label = $Label
		if is_equipped:
			item_label.visible = true
			item_label.text = type +" "+ "equipped"
			item_label.add_theme_font_size_override("font_size", 40)
			await get_tree().create_timer(1).timeout
			item_label.visible = false
		else:
			item_label.visible = true
			item_label.text = type +" "+ "unequipped"
			item_label.add_theme_font_size_override("font_size", 40)
			await get_tree().create_timer(1).timeout
			item_label.visible = false
