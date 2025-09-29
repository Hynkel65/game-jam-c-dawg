extends Control
@onready var main_buttons: VBoxContainer = $main_buttons
@onready var options: Control = $options
@onready var b_new_game: Button = $main_buttons/New_game
@onready var b_continue: Button = $main_buttons/Continue
@onready var b_options: Button = $main_buttons/Options
@onready var b_exit: Button = $main_buttons/Exit

func _ready() -> void:
	main_buttons.visible = true
	options.visible = false

func _on_continue_pressed() -> void:
	GlobalAudioPlayer.play_pressed()
	SaveManager.load_game()
	get_tree().change_scene_to_file("res://Scene/world.tscn")

func _on_options_pressed() -> void:
	GlobalAudioPlayer.play_pressed()
	main_buttons.visible = false
	options.open()

func _on_exit_pressed() -> void:
	GlobalAudioPlayer.play_pressed()
	get_tree().quit()

func _on_new_game_pressed() -> void:
	GlobalAudioPlayer.play_pressed()
	SaveManager.reset_save()
	get_tree().change_scene_to_file("res://Scene/world.tscn")

func _process(_delta: float) -> void:
	if options.visible == false:
		main_buttons.visible = true
