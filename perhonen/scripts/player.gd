extends CharacterBody2D


@export var move_speed = 600.0
@export var jump_velocity = -1200.0
@export var attack_rate = 0.25

@onready var graphics = $AnimatedSprite2D
@onready var attack_area = $AttackArea
@onready var down_attack_area = $DownAttackArea
@onready var up_attack_area = $UpAttackArea
@onready var ground_detect = $GroundDetect
@onready var timer = $Timer

var jump_cancelled = false
var going_right = true
var is_attacking_to_side = false
var is_attacking_up = false
var is_attacking = false
var getting_knockback = false
var is_pogo = false
var direction = 1
var is_hurting = false
var is_jumping = false
var is_dead = false

var knockback_direction: Vector2

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var friend = preload("res://scenes/friend.tscn")
var ui


func _ready():
	ui = get_tree().get_first_node_in_group("UI")
	attack_area.monitoring = false
	PlayerTracker.can_move = true
	timer.start(0.9)
	await timer.timeout
	spawn_friends()

func _physics_process(delta):
	if is_dead:
		return
	if !PlayerTracker.can_move:
		velocity.x = 0
		return
	
	handle_movement()
	handle_attacking()
	handle_jumping(delta)


func handle_movement():
	var move_direction = Input.get_axis("move_l", "move_r")
	
	if !is_attacking_to_side and !is_attacking_up:
		if !getting_knockback:
			if move_direction:
				velocity.x = move_direction * move_speed
			else:
				velocity.x = move_toward(velocity.x, 0, 60)
		
			if move_direction > 0:
				direction = 1
				attack_area.scale.x = 1
			elif move_direction < 0:
				direction = -1
				attack_area.scale.x = -1
		
		if move_direction < 0:
			going_right = false
			if !is_jumping:
				graphics.play("run_L")
		elif move_direction > 0:
			going_right = true
			if !is_jumping:
				graphics.play("run_R")
		else:
			if going_right:
				if !is_jumping:
					graphics.play("idle_R")
				if !is_attacking_to_side:
					attack_area.scale.x = 1
			else:
				if !is_jumping:
					graphics.play("idle_L")
				if !is_attacking_to_side:
					attack_area.scale.x = -1
	else:
		velocity.x = 0
	
	
	move_and_slide()


func handle_jumping(delta):
	if not is_on_floor():
		if is_jumping and !is_attacking:
			if going_right:
				graphics.play("jump_R")
			else:
				graphics.play("jump_L")
		if jump_cancelled and velocity.y < 0 and !is_pogo:
			velocity.y += gravity * delta * 6
		else:
			velocity.y += gravity * delta * 3
			if Input.is_action_just_released("jump") and velocity.y < 0:
				jump_cancelled = true
	else:
		is_jumping = false
		is_pogo = false
		jump_cancelled = false
		if Input.is_action_just_pressed("jump") and !is_attacking:
			if going_right and !is_attacking:
				graphics.play("jump_R")
			elif !going_right and !is_attacking:
				graphics.play("jump_L")
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
	print("Attacked")
	is_attacking_to_side = true
	is_attacking = true
	
	if going_right:
		graphics.play("attack_R")
	else:
		graphics.play("attack_L")
	
	timer.start(0.33)
	await timer.timeout
	take_damage(1, false)
	attack_area.set_deferred("monitoring", true)
	
	timer.start(0.33)
	await timer.timeout
	attack_area.set_deferred("monitoring", false)
	
	timer.start(0.15)
	await timer.timeout
	is_attacking_to_side = false
	is_attacking = false


func attack_down():
	print("Attacked down")
	take_damage(1, false)
	is_attacking = true
	down_attack_area.set_deferred("monitoring", true)
	
	timer.start(0.2)
	await timer.timeout
	
	is_attacking = false
	down_attack_area.set_deferred("monitoring", false)

func attack_up():
	print("Attacked up")
	take_damage(1, false)
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


func take_damage(damage_to_take, play_anim):
	if !is_hurting and PlayerTracker.can_move:
		if play_anim:
			$HurtAnimation.play("hurt")
		is_hurting = true
		PlayerTracker.health -= damage_to_take
		ui.update_health()
		print("Player health: " + str(PlayerTracker.health))
		if PlayerTracker.health <= 0:
			death()
		
		timer.start(0.25)
		await timer.timeout
		is_hurting = false


func death():
	is_dead = true
	velocity = Vector2.ZERO
	PlayerTracker.last_door_entered = "Down"
	PlayerTracker.health = PlayerTracker.max_health
	
	timer.start(0.5)
	await timer.timeout
	
	if PlayerTracker.last_checkpoint == "":
		get_tree().change_scene_to_file("res://scenes/phase1/phase1_start.tscn")
	else:
		get_tree().change_scene_to_file(PlayerTracker.last_checkpoint)


func spawn_friends():
	if PlayerTracker.player_damage > 1:
		for n in PlayerTracker.player_damage - 1:
			var instance = friend.instantiate()
			if instance != null:
				instance.position = position
				get_tree().current_scene.call_deferred("add_child", instance)


func _on_attack_area_body_entered(body):
	if body.is_in_group("Enemy"):
		body.take_damage(PlayerTracker.player_damage + 1)
		#knockback(-direction)


func _on_down_attack_area_body_entered(body):
	if body.is_in_group("Enemy"):
		body.take_damage(PlayerTracker.player_damage)
		down_attack_area.set_deferred("monitoring", false)
		velocity.y = jump_velocity / 2
		is_pogo = true
	if body.is_in_group("SolidDanger"):
		velocity.y = jump_velocity / 2
		is_pogo = true
		down_attack_area.set_deferred("monitoring", false)


func _on_up_attack_area_body_entered(body):
	if body.is_in_group("Enemy"):
		up_attack_area.set_deferred("monitoring", false)
		body.take_damage(PlayerTracker.player_damage)
		if velocity.y < 0:
			velocity.y = 0
