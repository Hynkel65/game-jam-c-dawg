extends Control

@onready var ability_text: Label = $PanelContainer/VBoxContainer/ability_text
@onready var popup_ability_gain: Control = $"."

func _ready(message="yep") -> void:
	set_msg(message)

func set_msg(text = ""):
	ability_text.set_text(text)
