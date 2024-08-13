extends CharacterBody2D


@export var move_speed = 600.0
@export var jump_velocity = -1200.0
@export var attack_rate = 0.25

@onready var graphics = $AnimatedSprite2D
@onready var attack_area = $AttackArea

var jump_cancelled = false
var going_right = true
var is_attacking = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _ready():
	attack_area.monitoring = false

func _physics_process(delta):
	if Input.is_action_just_pressed("attack") and !is_attacking:
		attack()
	
	if not is_on_floor():
		if jump_cancelled and velocity.y < 0:
			velocity.y += gravity * delta * 6
		else:
			velocity.y += gravity * delta * 3
			if Input.is_action_just_released("jump") and velocity.y < 0:
				jump_cancelled = true
	else:
		jump_cancelled = false
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_velocity
	
	
	var direction = Input.get_axis("move_l", "move_r")
	if direction:
		velocity.x = direction * move_speed
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed)
	
	if !is_attacking:
		if direction > 0:
			attack_area.scale.x = 1
		elif direction < 0:
			attack_area.scale.x = -1
	
	if velocity.x < 0:
		going_right = false
	elif velocity.x > 0:
		going_right = true
	else:
		if going_right:
			graphics.play("idle_R")
		else:
			graphics.play("idle_L")

	move_and_slide()

func attack():
	is_attacking = true
	attack_area.monitoring = true
	
	#if going_right:
		#graphics.play("attack_R")
	#else:
		#graphics.play("attack_L")
	
	await get_tree().create_timer(attack_rate).timeout
	attack_area.monitoring = false
	is_attacking = false


func _on_attack_area_body_entered(body):
	print("Something hit the attack area: " + str(body.name))
	pass # Replace with function body.
