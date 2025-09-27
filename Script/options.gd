extends Control

#func _ready():
	#option_buttons.visible = true
#
#func open():
	#option_buttons.visible = false
#
#func close():
	#option_buttons.visible = true
	#
func _on_back_pressed() -> void:
	#close()
	get_tree().change_scene_to_file("res://Scene/main_menu.tscn")
