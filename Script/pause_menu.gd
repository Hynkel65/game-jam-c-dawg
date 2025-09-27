extends Control

@onready var panel_container: PanelContainer = $PanelContainer

func _ready():
	panel_container.visible = false

func resume():
	get_tree().paused = false
	panel_container.visible = false

func pause():
	get_tree().paused = true
	panel_container.visible = true

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
	
func _on_main_menu_pressed() -> void:
	print("return to main menu")
	resume()
	get_tree().change_scene_to_file("res://Scene/main_menu.tscn")

func _process(delta: float) -> void:
	pressesc()
