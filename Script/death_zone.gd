extends Node

func _on_body_entered(body: Node2D):
	print("Collision detected with body: ", body.name) 
	if body is CharacterBody2D and body.has_method("die"):
		body.die()
