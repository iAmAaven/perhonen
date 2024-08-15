extends CharacterBody2D


@export var damage: int = 1
@export var move_speed = 600.0
@export var jump_velocity = -1200.0
@export var attack_rate = 0.25

@onready var graphics = $AnimatedSprite2D
@onready var attack_area = $AttackArea
@onready var down_attack_area = $DownAttackArea
@onready var up_attack_area = $UpAttackArea
@onready var ground_detect = $GroundDetect

var jump_cancelled = false
var going_right = true
var is_attacking = false
var getting_knockback = false
var is_pogo = false
var direction = 1
var is_hurting = false

var knockback_direction: Vector2

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _ready():
	attack_area.monitoring = false

func _physics_process(delta):
	
	if !is_attacking:
		if !is_on_floor() and Input.is_action_pressed("aim_down") and Input.is_action_just_pressed("attack"):
			attack_down()
		elif Input.is_action_pressed("aim_up") and Input.is_action_just_pressed("attack"):
			attack_up()
		elif Input.is_action_just_pressed("attack"):
			attack()
	
	if not is_on_floor():
		if jump_cancelled and velocity.y < 0 and !is_pogo:
			velocity.y += gravity * delta * 6
		else:
			velocity.y += gravity * delta * 3
			if Input.is_action_just_released("jump") and velocity.y < 0:
				jump_cancelled = true
	else:
		is_pogo = false
		jump_cancelled = false
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_velocity
	
	
	var move_direction = Input.get_axis("move_l", "move_r")
	
	if !getting_knockback:
		if move_direction:
			velocity.x = move_direction * move_speed
		else:
			velocity.x = move_toward(velocity.x, 0, move_speed)
	
	if !is_attacking:
		if move_direction > 0:
			direction = 1
			attack_area.scale.x = 1
		elif move_direction < 0:
			direction = -1
			attack_area.scale.x = -1
	
	if move_direction < 0:
		going_right = false
	elif move_direction > 0:
		going_right = true
	else:
		if going_right:
			graphics.play("idle_R")
			if !is_attacking:
				attack_area.scale.x = 1
		else:
			graphics.play("idle_L")
			if !is_attacking:
				attack_area.scale.x = -1

	move_and_slide()

func attack():
	print("Attacked")
	is_attacking = true
	attack_area.monitoring = true
	
	#if going_right:
		#graphics.play("attack_R")
	#else:
		#graphics.play("attack_L")
	
	await get_tree().create_timer(attack_rate).timeout
	attack_area.monitoring = false
	is_attacking = false


func attack_down():
	print("Attacked down")
	is_attacking = true
	down_attack_area.monitoring = true
	await get_tree().create_timer(attack_rate).timeout
	is_attacking = false
	down_attack_area.monitoring = false

func attack_up():
	print("Attacked up")
	is_attacking = true
	up_attack_area.monitoring = true
	await get_tree().create_timer(attack_rate).timeout
	is_attacking = false
	up_attack_area.monitoring = false


func knockback(knockback_dir):
	getting_knockback = true
	velocity.x = knockback_dir * move_speed
	await get_tree().create_timer(0.15).timeout
	velocity.x = 0
	getting_knockback = false


func take_damage(damage_to_take):
	if !is_hurting:
		$HurtAnimation.play("hurt")
		is_hurting = true
		PlayerTracker.health -= damage_to_take
		print("Player health: " + str(PlayerTracker.health))
		if PlayerTracker.health <= 0:
			death()
		
		await get_tree().create_timer(0.25).timeout
		is_hurting = false


func death():
	print_debug("Player died")


func _on_attack_area_body_entered(body):
	if body.is_in_group("Enemy"):
		body.take_damage(damage)
		knockback(-direction)


func _on_down_attack_area_body_entered(body):
	if body.is_in_group("Enemy"):
		body.take_damage(damage)
		velocity.y = jump_velocity
		is_pogo = true


func _on_up_attack_area_body_entered(body):
	if body.is_in_group("Enemy"):
		body.take_damage(damage)
