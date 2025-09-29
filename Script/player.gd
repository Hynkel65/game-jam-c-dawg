extends CharacterBody2D
@onready var sfx_player: AnimationPlayer = $sfx_player

# Core Movement Variables
const SPEED = 100.0
const RUN_SPEED = 200.0

# Jump Variables
const JUMP_VELOCITY = -300.0
const WALL_JUMP_VELOCITY = -200.0
const WALL_JUMP_COOLDOWN_TIME = 0.5
const COYOTE_TIME = 0.1

# Dash Variables
const DASH_COOLDOWN_TIME = 1.0
const DASH_VELOCITY = 600.0
const DASH_DURATION = 0.15
const DOUBLE_TAP_TIME = 0.25

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Ability Variables (The Core Progression System)
var has_jump = false
var has_run = false
var has_wall_jump = false
var has_double_jump = false
var has_dash = false

var can_double_jump = false

var wall_jump_cooldown: float = 0.0
var dash_cooldown: float = 0.0
var dash_timer: float = 0.0
var last_move_action: String = ""
var double_tap_timer: float = 0.0
var coyote_timer: float = 0.0

var last_direction: float = 1.0

var sm = SaveManager 

func _ready():
	if sm:
		sm.load_game()
		
		# Load the state for every ability key
		has_jump = sm.get_ability_state("jump")
		has_run = sm.get_ability_state("run")
		has_double_jump = sm.get_ability_state("double_jump")
		has_wall_jump = sm.get_ability_state("wall_jump")
		has_dash = sm.get_ability_state("dash")
		
		if sm.player_position != Vector2.ZERO:
			# Apply the loaded global position
			global_position = sm.player_position
			print("Player position loaded to:", global_position)
	
	# Initialize internal state based on abilities
	can_double_jump = has_double_jump

# --- INPUT HANDLING FOR DOUBLE-TAP DASH ---
func _unhandled_input(event: InputEvent):
	if not has_dash or dash_cooldown > 0.0 or dash_timer > 0.0:
		return
	
	if event.is_action_pressed("move_left"):
		_check_for_double_tap("move_left", -1.0)
	elif event.is_action_pressed("move_right"):
		_check_for_double_tap("move_right", 1.0)
		
func _check_for_double_tap(current_action: String, direction: float):
	if last_move_action == current_action and double_tap_timer > 0.0:
		start_dash(direction)
		double_tap_timer = 0.0
		last_move_action = ""
	else:
		last_move_action = current_action
		double_tap_timer = DOUBLE_TAP_TIME
		
func start_dash(direction: float):
	velocity.x = direction * DASH_VELOCITY
	velocity.y = 0
	dash_timer = DASH_DURATION
	dash_cooldown = DASH_COOLDOWN_TIME
	last_direction = direction

# --- CORE PHYSICS PROCESSING ---
func _physics_process(delta):
	# --- Cooldowns and Timers ---
	if wall_jump_cooldown > 0.0:
		wall_jump_cooldown -= delta
		
	if dash_cooldown > 0.0:
		dash_cooldown -= delta
		
	if double_tap_timer > 0.0:
		double_tap_timer -= delta
	
	if dash_timer > 0.0:
		dash_timer -= delta
		if dash_timer <= 0.0:
			velocity.y = 0
			velocity.x = 0 
			
	# --- Dash Movement Logic (Higher Priority) ---
	if dash_timer > 0.0:
		move_and_slide()
		return

	# --- Apply Gravity ---
	if not is_on_floor():
		velocity.y += gravity * delta
		
		if coyote_timer > 0.0:
			coyote_timer -= delta
		
		var horizontal_input = Input.get_axis("move_left", "move_right")
		if is_on_wall():
			if wall_jump_cooldown <= 0.0 and sign(horizontal_input) == -get_wall_normal().x and horizontal_input != 0:
				velocity.y = min(velocity.y, 10.0)
	else: 
		can_double_jump = has_double_jump
		wall_jump_cooldown = 0.0
		coyote_timer = COYOTE_TIME

	# 2. Handle Jump Input
	if Input.is_action_just_pressed("jump") and has_jump:
		# Jump logic remains the same...
		if coyote_timer > 0.0 and is_on_floor():
			velocity.y = JUMP_VELOCITY
		
		# WALL JUMP MECHANIC
		elif has_wall_jump and is_on_wall():
			var wall_normal = get_wall_normal()
			velocity.x = -wall_normal.x * WALL_JUMP_VELOCITY
			velocity.y = JUMP_VELOCITY
			last_direction = velocity.x
			wall_jump_cooldown = WALL_JUMP_COOLDOWN_TIME
		
		# DOUBLE JUMP MECHANIC
		elif can_double_jump:
			velocity.y = JUMP_VELOCITY
			sfx_player.play("sfx_jump")
			can_double_jump = false

	# 3. Handle Horizontal Movement
	var direction = Input.get_axis("move_left", "move_right")
	if wall_jump_cooldown <= 0.0:
		if direction and has_run:
			velocity.x = direction * RUN_SPEED
			last_direction = direction
		elif direction:
			velocity.x = direction * SPEED
			last_direction = direction
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED * 0.2)
	
	move_and_slide()
	
	# Animation
	if dash_timer > 0.0:
		$AnimatedSprite2D.animation = "Dash"
		pass
	elif not is_on_floor():
		if velocity.y < 0:
			$AnimatedSprite2D.animation = "Jump"
			$AnimatedSprite2D.flip_h = last_direction < 0
			sfx_player.play("sfx_jump")
		elif velocity.y > 0:
			if is_on_wall():
				$AnimatedSprite2D.animation = "Cling"
				$AnimatedSprite2D.flip_h = last_direction > 0
			else:
				# Simple Fall
				$AnimatedSprite2D.animation = "Fall"
				$AnimatedSprite2D.flip_h = last_direction < 0
			
	elif velocity.x != 0:
		# Running/Walking on the floor
		if has_run:
			$AnimatedSprite2D.play("Run")
			$AnimatedSprite2D.flip_h = last_direction < 0
			sfx_player.play("sfx_run")
		else:
			$AnimatedSprite2D.play("Walk")
			$AnimatedSprite2D.flip_h = last_direction < 0
			sfx_player.play("sfx_walk")
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
		"jump":
			if not has_jump:
				has_jump = true
				state_changed = true
		
		"run":
			if not has_run:
				has_run = true
				state_changed = true
		
		"double_jump":
			if not has_double_jump:
				has_double_jump = true
				state_changed = true
				
		"wall_jump":
			if not has_wall_jump:
				has_wall_jump = true
				state_changed = true
		
		"dash":
			if not has_dash:
				has_dash = true
				state_changed = true
		_:
			print("WARNING: Tried to unlock unknown ability: ", ability_name)
	
	if state_changed:
		sm.set_ability_state(ability_name, true)
		sm.save_game(self)
		print("Ability Unlocked: ", ability_name)
	
	# Optional: Show UI update here
	
func die():
	set_process_unhandled_input(false)
	set_physics_process(false)
	
	$AnimatedSprite2D.play("Death")
	
	print("You Are Dead")
	
	var timer = get_tree().create_timer(3.0)
	await timer.timeout
	
	get_tree().reload_current_scene()
