extends Control

#@onready var pause_panel: PanelContainer = $PanelContainer
@onready var pause_menu: Control = $"."

func _ready():
	pause_menu.visible = false

func resume():
	get_tree().paused = false
	pause_menu.visible = false

func pause():
	get_tree().paused = true
	pause_menu.visible = true

func pressesc():
	if Input.is_action_just_pressed("Pause") and !get_tree().paused:
		pause()
	elif Input.is_action_just_pressed("Pause") and get_tree().paused:
		resume()

func _on_resume_pressed() -> void:
	resume()

func _on_restart_pressed() -> void:
	resume()
	get_tree().reload_current_scene()
	
func _on_options_pressed() -> void:
	print("options")
	$options.open()

func _on_main_menu_pressed() -> void:
	SaveManager.save_game()
	resume()
	get_tree().change_scene_to_file("res://Scene/main_menu.tscn")

func _process(delta: float) -> void:
	pressesc()
