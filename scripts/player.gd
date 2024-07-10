extends CharacterBody2D


const SPEED = 130.0
const JUMP_VELOCITY = -300.0
const DOUBLE_JUMP_VEL = -600.0
const COYOTE_FRAMES = 4 # inclusive
const JUMP_BUFFER = 5
const queue = preload("res://scripts/queue.gd")


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var has_double_jump = true
var air_time = 0   # measured in frames
var jump_buffer = queue.new(JUMP_BUFFER)

@onready var animated_sprite = $AnimatedSprite2D

func _physics_process(delta):
	# Add the gravity & air time
	if not is_on_floor():
		velocity.y += gravity * delta
		air_time += 1 * delta

	# Handle jump, double jump, & coyote frames
	if Input.is_action_just_pressed("jump"): # and is_on_floor():
		if is_on_floor or air_time < COYOTE_FRAMES:
			velocity.y = JUMP_VELOCITY
		#elif not air_time > COYOTE_FRAMES:  # has coyote?
			#velocity.y = JUMP_VELOCITY
		elif has_double_jump:
			velocity.y = DOUBLE_JUMP_VEL
			has_double_jump = false
	
	#if Input.is_action_pressed("jump") and not is_on_floor():
		#jump_buffer.enqueue(true)
	
	if is_on_floor():
		if not has_double_jump:
			has_double_jump = true
		if air_time > 0:
			air_time = 0
	# Get the input direction and handle the movement/deceleration.
	# Negative is left
	var direction = Input.get_axis("move_left", "move_right")
	
	#Flip sprite based on walk direction
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0: # when condition is else and not elif, sprite flips left instantly when no key pressed
		animated_sprite.flip_h = true
	
	
	# play anims
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	if Input.is_action_just_pressed("jump"):
		animated_sprite.play("jump")
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
