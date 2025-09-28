extends Area2D

@export var ability_name: String = "" 
@export var pal_visual_name: String = ""

var rescued = false

func _ready():
	if SaveManager.get_ability_state(ability_name):
		hide_pal()
		rescued = true
		
func hide_pal():
	$Sprite2D.visible = false
	$CollisionShape2D.call_deferred("set_disabled", true)

# Connect the Area2D signal: body_entered(body: Node2D)
func _on_body_entered(body):
	print("Collision detected with body: ", body.name) 
	if body is CharacterBody2D and not rescued:
		print("Body is CharacterBody2D and pal is not rescued. Proceeding to unlock.")
		# Check if the colliding body is the player
		if body.has_method("unlock_ability"):
			print("Player has unlock_ability method. Unlocking: ", ability_name)
			body.unlock_ability(ability_name)
			
			# Visually remove/hide the Pal and mark as rescued
			hide_pal()
			rescued = true
			print("Pal '", pal_visual_name, "' rescued! Ability unlocked: ", ability_name)
		else:
			print("ERROR: CharacterBody2D does not have the 'unlock_ability' method.")
	elif rescued:
		print("Pal already rescued. Ignoring collision.")
	else:
		print("Collision body is not the expected CharacterBody2D (Player). Ignoring.")
			
			# Optional: Play a sound effect or particle effect
