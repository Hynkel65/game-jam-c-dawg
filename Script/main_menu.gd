extends Control

func _on_continue_pressed() -> void:
	SaveManager.load_game()
	get_tree().change_scene_to_file("res://Scene/world.tscn")

func _on_options_pressed() -> void:
	print("Options Pressed")
	$options.open()
	#get_tree().change_scene_to_file("res://Scene/options.tscn")

func _on_exit_pressed() -> void:
	print("Exit Pressed")
	get_tree().quit()

func _on_new_game_pressed() -> void:
	print("New Game Pressed")
