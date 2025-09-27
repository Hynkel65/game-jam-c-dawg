extends Control

@onready var options: Control = $"."

func _ready():
	options.visible = false
	
func open():
	options.visible = true

func close():
	options.visible = false
	
func _on_back_pressed() -> void:
	close()
	#get_tree().change_scene_to_file("res://Scene/main_menu.tscn")
