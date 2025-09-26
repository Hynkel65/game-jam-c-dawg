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

# --- CORE PHYSICS PROCESSING ---
func _physics_process(delta):	
	# 1. Apply Gravity
	if not is_on_floor():
		velocity.y += gravity * delta
		
		# WALL CLING MECHANIC (Rescued Pal #2)
		var horizontal_input = Input.get_axis("move_left", "move_right")
		if has_wall_climb and horizontal_input != 0 and is_on_wall():
			# 'is_on_wall()' is enough here because it's called every frame.
			# We clamp velocity.y to slow the descent, creating the cling effect.
			velocity.y = min(velocity.y, 50.0) # Slow fall down wall
			# Optionally, set velocity.x to 0 here to truly stick, but move_and_slide handles it
			
	else: # Reset double jump only when touching the floor
		can_double_jump = has_double_jump

	# 2. Handle Jump Input
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
			can_double_jump = has_double_jump # Reset double jump availability
		
		# DOUBLE JUMP MECHANIC (Rescued Pal #1)
		elif can_double_jump: # Check if the *ability* is unlocked AND *not used* in the air
			velocity.y = JUMP_VELOCITY
			can_double_jump = false # Consume the double jump

	# 3. Handle Horizontal Movement
	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * 0.1)

	# 4. Use built-in function to move the body
	move_and_slide()
	
	# Animation
	if not is_on_floor():
		# WALL CLING ANIMATION CHECK
		if has_wall_climb and is_on_wall() and velocity.y > 0 and direction != 0:
			# If clinging to a wall, use a specific animation or the Fall one
			$AnimatedSprite2D.animation = "Cling" # Assuming you have a "Cling" animation
		elif velocity.y < 0:
			$AnimatedSprite2D.animation = "Jump"
		else: # velocity.y >= 0 (Falling)
			$AnimatedSprite2D.animation = "Fall"
			
	elif velocity.x != 0:
		# Running/Moving on the floor
		$AnimatedSprite2D.play("Move")
		$AnimatedSprite2D.flip_h = direction < 0
	else:
		# Idle (Standing still on the floor)
		$AnimatedSprite2D.play("Idle")

# --- ABILITY UNLOCK FUNCTION ---
func unlock_ability(ability_name):
	match ability_name:
		"double_jump":
			has_double_jump = true
			# Also grant the first double jump immediately if we're in the air
			can_double_jump = true 
			print("Ability Unlocked: Double Jump!")
		"wall_climb":
			has_wall_climb = true
			print("Ability Unlocked: Wall Climb!")
	
	# Optional: Show UI update here
