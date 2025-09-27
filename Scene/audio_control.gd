extends HSlider

@export var audio_bus_name : String

var audio_bus_id

func _ready():
	audio_bus_id = AudioServer.get_bus_index(audio_bus_name)

func _on_audio_control_value_changed(val) -> void:
	var db = linear_to_db(val)
	AudioServer.set_bus_volume_db(audio_bus_id, db)
