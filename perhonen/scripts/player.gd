extends CharacterBody2D

@export var move_speed = 600.0
@export var jump_velocity = -1200.0


@onready var graphics = $AnimatedSprite2D
@onready var attack_area = $AttackArea
@onready var down_attack_area = $DownAttackArea
@onready var up_attack_area = $UpAttackArea
@onready var timer = $Timer

var move_direction
var jump_cancelled = false
var going_right = true
var is_attacking = false
var is_attacking_to_side = false
var is_attacking_up = false
var is_jumping = false
var is_pogo = false
var is_hurting = false
var is_dead = false
var getting_knockback = false
var direction = 1
var coyote_time = 0.1
var coyote_time_counter = 0.0
var knockback_direction: Vector2
var ui
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var friend = preload("res://scenes/friend.tscn")

func _ready():
	ui = get_tree().get_first_node_in_group("UI")
	attack_area.monitoring = false
	PlayerTracker.able_to_move = true
	timer.start(0.1)
	await timer.timeout
	spawn_friends()

func _physics_process(delta):
	if is_dead:
		return
	if !PlayerTracker.able_to_move:
		velocity.x = 0
		return
	
	handle_movement(delta)
	handle_attacking()
	handle_jumping(delta)


func update_coyote_time(delta):
	if is_on_floor():
		coyote_time_counter = coyote_time
	else:
		coyote_time_counter -= delta


func handle_movement(delta):
	update_coyote_time(delta)
	
	move_direction = Input.get_axis("move_l", "move_r")
	if is_attacking or getting_knockback:
		velocity.x = 0
		move_and_slide()
		return
	
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
		attack_area.scale.x = 1
		going_right = true
	elif move_direction < 0:
		direction = -1
		attack_area.scale.x = -1
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
	
	if coyote_time_counter > 0.0 and !is_jumping:
		if Input.is_action_just_pressed("jump") and !is_attacking:
			start_jump()
	
	if jump_cancelled and velocity.y < 0 and !is_pogo:
		velocity.y += gravity * delta * 6
	else:
		velocity.y += gravity * delta * 3
		if Input.is_action_just_released("jump") and velocity.y < 0:
			jump_cancelled = true


func reset_jump_state():
	is_jumping = false
	is_pogo = false
	jump_cancelled = false


func start_jump():
	velocity.y = jump_velocity
	is_jumping = true


func handle_attacking():
	if !is_attacking:
		if !is_on_floor() and Input.is_action_pressed("aim_down") and Input.is_action_just_pressed("attack"):
			attack_down()
		elif Input.is_action_pressed("aim_up") and Input.is_action_just_pressed("attack"):
			attack_up()
		elif Input.is_action_just_pressed("attack"):
			attack()


func attack():
	is_attacking = true
	is_attacking_to_side = true
	if going_right: graphics.play("attack_R")
	else: graphics.play("attack_L")
	
	timer.start(0.33)
	await timer.timeout
	attack_area.set_deferred("monitoring", true)
	
	timer.start(0.33)
	await timer.timeout
	attack_area.set_deferred("monitoring", false)
	
	timer.start(0.15)
	await timer.timeout
	is_attacking_to_side = false
	is_attacking = false


func attack_down():
	is_attacking = true
	down_attack_area.set_deferred("monitoring", true)
	
	timer.start(0.2)
	await timer.timeout
	
	is_attacking = false
	down_attack_area.set_deferred("monitoring", false)


func attack_up():
	is_attacking = true
	is_attacking_up = true
	up_attack_area.set_deferred("monitoring", true)
	
	timer.start(0.2)
	await timer.timeout
	
	is_attacking_up = false
	up_attack_area.set_deferred("monitoring", false)
	
	timer.start(0.3)
	await timer.timeout
	
	is_attacking = false


func knockback(knockback_dir):
	getting_knockback = true
	velocity.x = knockback_dir * move_speed
	
	timer.start(0.075)
	await timer.timeout
	
	velocity.x = 0
	getting_knockback = false


func take_damage():
	if is_hurting or !PlayerTracker.able_to_move:
		return
	
	$HurtAnimation.play("hurt")
	is_hurting = true
	PlayerTracker.health -= 1
	ui.update_health()
	print("Player health: %s" % PlayerTracker.health)
	
	if PlayerTracker.health <= 0:
		death()
	
	timer.start(0.25)
	await timer.timeout
	is_hurting = false


func death():
	is_dead = true
	velocity = Vector2.ZERO
	graphics.play("idle_R")
	PlayerTracker.last_door_entered = "Down"
	PlayerTracker.health = PlayerTracker.max_health
	ui.update_health()
	
	print_debug("Player died. Add death animation and respawning...")
	
	timer.start(0.5)
	await timer.timeout
	
	is_dead = false


func spawn_friends():
	if PlayerTracker.player_damage > 1:
		for n in PlayerTracker.player_damage - 1:
			var instance = friend.instantiate()
			instance.position = position
			get_tree().current_scene.call_deferred("add_child", instance)


func _on_attack_area_body_entered(body):
	if body.is_in_group("Enemy"):
		body.take_damage(PlayerTracker.player_damage)


func _on_down_attack_area_body_entered(body):
	if body.is_in_group("Enemy") or body.is_in_group("SolidDanger"):
		body.take_damage(PlayerTracker.player_damage)
		down_attack_area.set_deferred("monitoring", false)
		velocity.y = jump_velocity / 2
		is_pogo = true


func _on_up_attack_area_body_entered(body):
	if body.is_in_group("Enemy"):
		up_attack_area.set_deferred("monitoring", false)
		body.take_damage(PlayerTracker.player_damage)
		if velocity.y < 0:
			velocity.y = 0
