# SaveManager.gd

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

# REMOVE: var player = preload("res://Scene/world.tscn")

var abilities: Dictionary = {}
var player_position: Vector2 = Vector2.ZERO # Store loaded position here

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
		# Note: The Player script will now call save_game with its reference
		# in unlock_ability, and you'll update save_game below.
		# For general state changes, you might need a reference or a separate function.

# New function to save both abilities and the player's position
func save_game(player_node: CharacterBody2D):	
	
	var player_pos_array = [player_node.global_position.x, player_node.global_position.y]
	
	var save_dict = {
		"abilities": abilities,
		"position": player_pos_array,
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
				for key in loaded_data.abilities.keys():
					if key in ALL_ABILITY_KEYS: # Check against the master list
						abilities[key] = loaded_data.abilities[key]
			
			# Load Position
			if loaded_data.has("position"):
				var loaded_position = loaded_data.position
				
				# ⚠️ CRITICAL FIX: Expect an Array and convert it back to Vector2
				if loaded_position is Array and loaded_position.size() == 2:
					# Array: [x, y]
					player_position = Vector2(loaded_position[0], loaded_position[1])
				elif loaded_position is Dictionary:
					# Fallback for if it was saved as {"x": float, "y": float}
					if loaded_position.has("x") and loaded_position.has("y"):
						player_position = Vector2(loaded_position.x, loaded_position.y)
					else:
						# Default if data is corrupted
						player_position = Vector2.ZERO
						print("WARNING: Position Dictionary in save file is incomplete.")
				else:
					player_position = Vector2.ZERO
					print("WARNING: Position data in save file is in an unexpected format.")
				
			print("Game Loaded Successfully!")
			return true
		else:
			print("ERROR: Failed to parse save file.")
			return false
	else:
		print("ERROR: Could not open save file for loading.")
		return false

# Updated reset_save to use the new position variable
func reset_save():
	set_default_ability()
	player_position = Vector2.ZERO # Reset saved position
	var save_dict = {
		"abilities": abilities,
		"position": player_position,
	}
	
	var json_string = JSON.stringify(save_dict, "\t")
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_line(json_string)
		print("New game Saved Successfully!")
		file.close()
	else:
		print("ERROR: Could not save game to path:", SAVE_PATH)
