extends Node
@warning_ignore("unused_signal")
signal open_up
@warning_ignore("unused_signal")
signal cause_a_problem

var code_array: Array = []
func _on_button_effect(code: String)->void:
	code_array.append(code)
	if code_array.size() > 5:
		if code_array == ["6", "6", "1", "6", "5", "4"]:
			emit_signal("open_up")
			code_array.clear()
		else:
			emit_signal("cause_a_problem")
			code_array.clear()
	
