extends CharacterBody2D

# Core Movement Variables
const SPEED = 200.0
const JUMP_VELOCITY = -450.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Ability Variables (The Core Progression System)
var has_double_jump = false
var has_wall_climb = false
# Add more booleans for each pal you plan to rescue!

# Variable to track if a double jump has been used since leaving the ground
var can_double_jump = false

var last_direction: float = 1.0

var sm = SaveManager 

func _ready():
	if sm:
		sm.load_game()
		
		# Load the state for every ability key
		has_double_jump = sm.get_ability_state("double_jump")
		has_wall_climb = sm.get_ability_state("wall_climb")
	
	# Initialize internal state based on abilities
	can_double_jump = has_double_jump

# --- CORE PHYSICS PROCESSING ---
func _physics_process(delta):	
	# --- Apply Gravity ---
	if not is_on_floor():
		velocity.y += gravity * delta
		
		# WALL CLING MECHANIC (Rescued Pal #2)
		var horizontal_input = Input.get_axis("move_left", "move_right")
		if has_wall_climb and horizontal_input != 0 and is_on_wall():
			velocity.y = min(velocity.y, 50.0) # Slow fall down wall
			
	else: # Reset double jump only when touching the floor
		can_double_jump = has_double_jump

	# 2. Handle Jump Input
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
			can_double_jump = has_double_jump # Reset double jump availability
		
		# DOUBLE JUMP MECHANIC (Rescued Pal #1)
		elif can_double_jump:
			velocity.y = JUMP_VELOCITY
			can_double_jump = false

	# 3. Handle Horizontal Movement
	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
		last_direction = direction
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * 0.1)
		
	# 4. Use built-in function to move the body
	move_and_slide()
	
	# Animation
	if not is_on_floor():
		# WALL CLING ANIMATION CHECK
		if has_wall_climb and is_on_wall() and velocity.y > 0 and direction != 0:
			# If clinging to a wall, use a specific animation or the Fall one
			$AnimatedSprite2D.animation = "Cling"
			$AnimatedSprite2D.flip_h = last_direction > 0
		elif velocity.y < 0:
			$AnimatedSprite2D.animation = "Jump"
			$AnimatedSprite2D.flip_h = last_direction < 0
		else: # velocity.y >= 0 (Falling)
			$AnimatedSprite2D.animation = "Fall"
			$AnimatedSprite2D.flip_h = last_direction < 0
			
	elif velocity.x != 0:
		# Running/Moving on the floor
		$AnimatedSprite2D.play("Move")
		$AnimatedSprite2D.flip_h = last_direction < 0
	else:
		# Idle (Standing still on the floor)
		$AnimatedSprite2D.play("Idle")
		$AnimatedSprite2D.flip_h = last_direction < 0

# --- ABILITY UNLOCK FUNCTION (The central dispatcher)---
func unlock_ability(ability_name):
	if sm == null:
		print("ERROR: Save Manager is not initialized.")
		return
	
	var state_changed = false
	
	# Add new pal logic HERE!
	match ability_name:
		"double_jump":
			if not has_double_jump:
				has_double_jump = true
				sm.set_ability_state("has_double_jump", true)
				state_changed = true
				
		"wall_climb":
			if not has_wall_climb:
				has_wall_climb = true
				sm.set_ability_state("has_wall_climb", true)
				state_changed = true
				
		_:
			print("WARNING: Tried to unlock unknown ability: ", ability_name)
	
	if state_changed:
		sm.set_ability_state(ability_name, true)
		print("Ability Unlocked: ", ability_name)
	
	# Optional: Show UI update here
