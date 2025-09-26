extends Area2D

@export var ability_to_unlock: String = "double_jump" 
var rescued = false

# Connect the Area2D signal: body_entered(body: Node2D)
func _on_body_entered(body):
	if body is CharacterBody2D and not rescued:
		# Check if the colliding body is the player
		if body.has_method("unlock_ability"):
			body.unlock_ability(ability_to_unlock)
			
			# Visually remove/hide the Pal and mark as rescued
			$Sprite2D.visible = false
			$CollisionShape2D.disabled = true
			rescued = true
			
			# Optional: Play a sound effect or particle effect
