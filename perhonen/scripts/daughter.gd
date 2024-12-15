extends CharacterBody2D

@export var move_speed = 600.0
@export var jump_velocity = -1200.0

@onready var graphics = $AnimatedSprite2D
@onready var timer = $Timer

var move_direction
var jump_cancelled = false
var going_right = true
var is_jumping = false
var is_dead = false
var direction = 1
var coyote_time = 0.1
var coyote_time_counter = 0.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var ui

func _ready():
	ui = get_tree().get_first_node_in_group("UI")
	PlayerTracker.able_to_move = true


func _physics_process(delta):
	if is_dead:
		return
	if !PlayerTracker.able_to_move:
		velocity.x = 0
		return
	
	handle_movement(delta)
	handle_jumping(delta)


func update_coyote_time(delta):
	if is_on_floor():
		coyote_time_counter = coyote_time
	else:
		coyote_time_counter -= delta


func handle_movement(delta):
	update_coyote_time(delta)
	
	move_direction = Input.get_axis("move_l", "move_r")
	
	update_direction()
	update_animation()
	
	if move_direction:
		velocity.x = move_direction * move_speed
	else:
		velocity.x = move_toward(velocity.x, 0, 60)
	
	
	move_and_slide()


func update_direction():
	if move_direction > 0:
		direction = 1
		going_right = true
	elif move_direction < 0:
		direction = -1
		going_right = false


func update_animation():
	if !is_jumping:
		if move_direction:
			if going_right: graphics.play("run_R")
			else: graphics.play("run_L")
		else:
			if going_right: graphics.play("idle_R")
			else: graphics.play("idle_L")
	else:
		if going_right: graphics.play("jump_R")
		else: graphics.play("jump_L")


func handle_jumping(delta):
	if is_on_floor():
		reset_jump_state()
	
	if coyote_time_counter > 0.0 and !is_jumping and Input.is_action_just_pressed("jump"):
		start_jump()
	
	if jump_cancelled and velocity.y < 0:
		velocity.y += gravity * delta * 6
	else:
		velocity.y += gravity * delta * 3
		if Input.is_action_just_released("jump") and velocity.y < 0:
			jump_cancelled = true


func reset_jump_state():
	is_jumping = false
	jump_cancelled = false


func start_jump():
	velocity.y = jump_velocity
	is_jumping = true


func take_damage():
	if !PlayerTracker.able_to_move:
		return
	
	death()


func death():
	is_dead = true
	velocity = Vector2.ZERO
	PlayerTracker.last_door_entered = "Down"
	
	print_debug("Player died. Add death animation and respawning...")
	
	timer.start(0.5)
	await timer.timeout
	
	is_dead = false
