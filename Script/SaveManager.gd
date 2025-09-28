extends Node

const SAVE_PATH = "user://game_save.dat"

# Define ALL possible ability keys here. This is the master list.
const ALL_ABILITY_KEYS = [
	"jump",
	"run", 
	"wall_jump",
	"double_jump",
	"dash"
]

var abilities: Dictionary = {}

# var player_position = Vector2.ZERO

func _ready():
	# Initialize abilities dictionary with default 'false' values from the master list
	set_default_ability()
		
	load_game()
	
# --- PUBLIC FUNCTIONS ---

# Function to set all ability to the default state 'false' 
func set_default_ability():
	for key in ALL_ABILITY_KEYS:
		abilities[key] = false

# Function to be called by the player to get the ability state
func get_ability_state(ability_name: String) -> bool:
	return abilities.get(ability_name, false)

# Function to be called by the player to set an ability state
func set_ability_state(ability_name: String, value: bool):
	if abilities.has(ability_name):
		abilities[ability_name] = value
		save_game()

# --- FILE HANDLING ---

func save_game():
	var save_dict = {
		"abilities": abilities,
		# "position": player_position,
	}
	
	var json_string = JSON.stringify(save_dict, "\t")
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_line(json_string)
		print("Game Saved Successfully!")
		file.close()
	else:
		print("ERROR: Could not save game to path:", SAVE_PATH)

func load_game():
	if not FileAccess.file_exists(SAVE_PATH):
		print("No save file found. Starting new game.")
		return false

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		var parse_result = JSON.parse_string(json_string)
		
		file.close()
		
		if parse_result is Dictionary:
			var loaded_data = parse_result
			
			# Load Abilities
			if loaded_data.has("abilities"):
				# Iterate over the saved abilities and update the SaveManager's state
				for key in loaded_data.abilities.keys():
					if abilities.has(key):
						if key in ALL_ABILITY_KEYS:
							abilities[key] = loaded_data.abilities[key]
			
			print("Game Loaded Successfully!")
			return true
		else:
			print("ERROR: Failed to parse save file.")
			return false
	else:
		print("ERROR: Could not open save file for loading.")
		return false

func reset_save():
	set_default_ability()
	var save_dict = {
		"abilities": abilities,
		#"position": player_position,
	}
	
	var json_string = JSON.stringify(save_dict, "\t")
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_line(json_string)
		print("New game Saved Successfully!")
		file.close()
	else:
		print("ERROR: Could not save game to path:", SAVE_PATH)
