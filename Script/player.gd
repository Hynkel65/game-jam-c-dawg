extends CharacterBody2D

# Core Movement Variables
const SPEED = 200.0
const JUMP_VELOCITY = -300.0
const WALL_JUMP_VELOCITY = -200.0
const WALL_JUMP_COOLDOWN_TIME = 0.5

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Ability Variables (The Core Progression System)
var has_double_jump = false
var has_wall_jump = false
# Add more booleans for each pal you plan to rescue!

# Variable to track if a double jump has been used since leaving the ground
var can_double_jump = false

var wall_jump_cooldown: float = 0.0

var last_direction: float = 1.0

var sm = SaveManager 

func _ready():
	if sm:
		sm.load_game()
		
		# Load the state for every ability key
		has_double_jump = sm.get_ability_state("double_jump")
		has_wall_jump = sm.get_ability_state("wall_jump")
	
	# Initialize internal state based on abilities
	can_double_jump = has_double_jump

# --- CORE PHYSICS PROCESSING ---
func _physics_process(delta):
	if wall_jump_cooldown > 0.0:
		wall_jump_cooldown -= delta
		
	# --- Apply Gravity ---
	if not is_on_floor():
		velocity.y += gravity * delta
		
		var horizontal_input = Input.get_axis("move_left", "move_right")
		if is_on_wall():
			if wall_jump_cooldown <= 0.0 and sign(horizontal_input) == -get_wall_normal().x and horizontal_input != 0:
				velocity.y = min(velocity.y, 50.0) # Slow the fall
	else: 
		can_double_jump = has_double_jump
		wall_jump_cooldown = 0.0

	# 2. Handle Jump Input
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
		
		# WALL JUMP MECHANIC (Rescued Pal #2) - Check before double jump
		elif has_wall_jump and is_on_wall():
			# Determine opposite direction of the wall (e.g., if wall is on the right, jump left)
			var wall_normal = get_wall_normal()
			
			# Apply the forced horizontal and vertical velocity
			velocity.x = -wall_normal.x * WALL_JUMP_VELOCITY
			velocity.y = JUMP_VELOCITY
			last_direction = velocity.x
			
			# START COOLDOWN: Player loses horizontal control briefly
			wall_jump_cooldown = WALL_JUMP_COOLDOWN_TIME
		
		# DOUBLE JUMP MECHANIC (Rescued Pal #1)
		elif can_double_jump:
			velocity.y = JUMP_VELOCITY
			can_double_jump = false

	# 3. Handle Horizontal Movement
	var direction = Input.get_axis("move_left", "move_right")
	if wall_jump_cooldown <= 0.0:
		if direction:
			velocity.x = direction * SPEED
			last_direction = direction
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED * 0.1)
	
	move_and_slide()
	
	# Animation
	if not is_on_floor():
		if velocity.y < 0:
			$AnimatedSprite2D.animation = "Jump"
			$AnimatedSprite2D.flip_h = last_direction < 0
		elif velocity.y > 0:
			if is_on_wall():
				$AnimatedSprite2D.animation = "Cling"
				$AnimatedSprite2D.flip_h = last_direction > 0
			else:
				# Simple Fall
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
				state_changed = true
				
		"wall_jump":
			if not has_wall_jump:
				has_wall_jump = true
				state_changed = true
					
		_:
			print("WARNING: Tried to unlock unknown ability: ", ability_name)
	
	if state_changed:
		sm.set_ability_state(ability_name, true)
		sm.save_game()
		print("Ability Unlocked: ", ability_name)
	
	# Optional: Show UI update here
