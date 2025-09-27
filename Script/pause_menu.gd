extends Control

@onready var pause_menu: Control = $"."
@onready var options: Control = $options
@onready var pause_panel: PanelContainer = $pause_panel

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

func _on_reset_pressed() -> void:
	resume()
	get_tree().reload_current_scene()
	
func _on_options_pressed() -> void:
	print("options")
	pause_panel.visible = false
	options.open()
	
func _on_main_menu_pressed() -> void:
	print("return to main menu")
	resume()
	get_tree().change_scene_to_file("res://Scene/main_menu.tscn")

func _process(delta: float) -> void:
	pressesc()
	if options.visible == false:
		pause_panel.visible = true


func _on_restart_pressed() -> void:
	pass # Replace with function body.
