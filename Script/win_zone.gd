extends Node
@onready var popup_ability_gain: Control = $"../CanvasLayer/popup_ability_gain"
@onready var win_sfx: AudioStreamPlayer = $"../WinSFX"

func _on_body_entered(body: Node2D):
	print("Collision detected with body: ", body.name) 
	if body is CharacterBody2D and body.has_method("die"):
	
		popup_ability_gain.set_msg("You've reached the End of the game! We unfortunately started working on this quite late and had to just stop and sent in what we've made until this point")
		popup_ability_gain.visible = true
		win_sfx.play()
		var timer = get_tree().create_timer(5.0)
		await timer.timeout
		get_tree().change_scene_to_file("res://Scene/main_menu.tscn")
