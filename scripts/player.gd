extends CharacterBody2D


const REG_SPEED = 130.0
const SPRINT_SPEED = 190.0
const DASH_SPEED = 600.0
const JUMP_VELOCITY = -300.0
const DOUBLE_JUMP_VEL = -250.0
const COYOTE_FRAMES = 4 # inclusive
const JUMP_BUFFER_FRAMES = 5
const queue = preload("res://scripts/queue.gd")
const STAMINA_MAX = 200
const DASH_FRAMES = 8
const DASH_COOLDOWN = 30

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var has_double_jump = true
var air_time = 0   # measured in frames
var jump_buffer = queue.new(JUMP_BUFFER_FRAMES + 300)
var is_jump_held = false

var curr_speed = REG_SPEED
var stamina = STAMINA_MAX


var dash_frames_remaining = DASH_FRAMES
var is_in_dash = false
var dash_cooldown = DASH_COOLDOWN
@onready var animated_sprite = $AnimatedSprite2D

func _ready():
	for i in range(JUMP_BUFFER_FRAMES):
		jump_buffer.enqueue(false)

func _physics_process(delta):
	# Add the gravity & air time
	if not is_on_floor():
		velocity.y += gravity * delta
		air_time += 1 #* delta
		# print(air_time)
		if Input.is_action_pressed("jump"):
			jump_buffer.enqueue(true)
		else:
			jump_buffer.enqueue(false)

	# Handle jump, double jump, & coyote frames
	if Input.is_action_just_pressed("jump"): # and is_on_floor():
		
		if is_on_floor() or air_time < COYOTE_FRAMES:
			if not is_jump_held:
				do_jump()
		#elif not air_time > COYOTE_FRAMES:  # has coyote?
			#velocity.y = JUMP_VELOCITY
		elif has_double_jump:
			do_double_jump()
			has_double_jump = false
		is_jump_held = true
	
	if Input.is_action_just_released("jump"):
		is_jump_held = false
	
	if is_on_floor():
		if not has_double_jump:
			has_double_jump = true
		if air_time > 0:
			air_time = 0
			if true in jump_buffer.peek_all().slice( 0, JUMP_BUFFER_FRAMES, 1) and false in jump_buffer.peek_all().slice(JUMP_BUFFER_FRAMES):
				is_jump_held = false
				do_jump()
		
		if not is_in_dash:
			if dash_cooldown > 0:
				dash_cooldown -= 1

	# Get the input direction and handle the movement/deceleration.
	# Negative is left
	var direction = Input.get_axis("move_left", "move_right")
	
	#Flip sprite based on walk direction
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0: # when condition is else and not elif, sprite flips left instantly when no key pressed
		animated_sprite.flip_h = true
	
	# dash
	if Input.is_action_just_pressed("dash") and dash_cooldown < 1: #not is_in_dash:
		is_in_dash = true
		dash_frames_remaining = DASH_FRAMES
		curr_speed = DASH_SPEED
	
	if is_in_dash:
		if dash_frames_remaining > 0:
			dash_frames_remaining -= 1
		else:
			is_in_dash = false
			curr_speed = REG_SPEED
			dash_cooldown = DASH_COOLDOWN
	
	
	
	# sprint
	if Input.is_action_pressed("sprint"):
		if not is_in_dash and stamina > 1:
			curr_speed = SPRINT_SPEED
			stamina -= 2
	else:
		if stamina < STAMINA_MAX:
			stamina += 1
		if not is_in_dash:
			curr_speed = REG_SPEED
	

	
	# play anims
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	if Input.is_action_just_pressed("jump"):
		animated_sprite.play("jump")
	
	if direction:
		velocity.x = direction * curr_speed
	else:
		velocity.x = move_toward(velocity.x, 0, curr_speed)

	move_and_slide()

func do_jump():

	velocity.y = JUMP_VELOCITY
	
func do_double_jump():
	
	velocity.y = DOUBLE_JUMP_VEL
