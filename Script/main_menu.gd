extends Control
@onready var main_buttons: VBoxContainer = $main_buttons
@onready var options: Control = $options

func _ready() -> void:
	main_buttons.visible = true
	options.visible = false

func _on_continue_pressed() -> void:
	SaveManager.load_game()
	get_tree().change_scene_to_file("res://Scene/world.tscn")

func _on_options_pressed() -> void:
	print("Options Pressed")
	main_buttons.visible = false
	options.open()
	#get_tree().change_scene_to_file("res://Scene/options.tscn")

func _on_exit_pressed() -> void:
	print("Exit Pressed")
	get_tree().quit()

func _on_new_game_pressed() -> void:
	print("New Game Pressed")

func _process(delta: float) -> void:
	if options.visible == false:
		main_buttons.visible = true
