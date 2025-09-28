extends Control

@onready var ability_text: RichTextLabel = $VBoxContainer/ability_text

func set_text(text):
	ability_text.add_text(text)
