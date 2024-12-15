extends Enemy


@onready var raycasts = $Raycasts
@onready var ground_detect = $Raycasts/GroundDetect
@onready var wall_detect = $Raycasts/WallDetect
@onready var graphics = $Graphics
@onready var cloud_spawn = $Raycasts/CloudSpawn
@onready var attack_timer = $Timer


var cloud = preload("res://scenes/dangers/cloud_of_self_doubt.tscn")

@export var normal_speed : int
@export var run_speed : int
var speed : int

var direction: int = -1
var is_running = false
var detecting_player = false
var player_is_inside_enemy = false
var preparing_run = false
var stopping_run = false


var player: Node2D = null

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _ready():
	player = get_tree().get_first_node_in_group("Player")


func _process(delta):
	if ground_detect.is_colliding() and !wall_detect.is_colliding():
		if !preparing_run:
			velocity.x = speed * direction
	else:
		velocity.x = 0
	
	velocity.y += gravity * delta * 3
	
	if velocity.x < 0:
		graphics.flip_h = false
	elif velocity.x > 0:
		graphics.flip_h = true
	
	if is_running:
		if $CloudTimer.is_stopped():
			spawn_cloud()
		if !stopping_run:
			if !ground_detect.is_colliding() or wall_detect.is_colliding():
				stop_running(0)
			elif direction < 0 and player.position.x > position.x:
				stop_running(1)
			elif direction >= 0 and player.position.x <= position.x:
				stop_running(1)
	else:
		if detecting_player and ground_detect.is_colliding():
			run_towards_player()
		elif detecting_player and !ground_detect.is_colliding():
			change_direction()
		elif !detecting_player:
			hang_around()
	
	move_and_slide()


func _on_detection_area_body_entered(body):
	if body.is_in_group("Player"):
		detecting_player = true
		if !is_running:
			run_towards_player()


func run_towards_player():
	if player.position.x < position.x:
		raycasts.scale.x = 1
		run(-1)
	elif player.position.x > position.x:
		raycasts.scale.x = -1
		run(1)
	else:
		is_running = false


func run(dir):
	preparing_run = true
	velocity.x = 0
	
	attack_timer.start(1)
	await attack_timer.timeout
	
	is_running = true
	preparing_run = false
	direction = dir
	speed = run_speed


func stop_running(time):
	stopping_run = true
	
	attack_timer.start(time)
	await attack_timer.timeout
	
	speed = 0
	change_direction()
	
	attack_timer.start(1)
	await attack_timer.timeout
	
	is_running = false
	speed = normal_speed
	stopping_run = false


func spawn_cloud():
	print("Spawned cloud")
	var instance = cloud.instantiate()
	if instance != null:
		instance.global_position = cloud_spawn.global_position
		get_tree().current_scene.call_deferred("add_child", instance)
	$CloudTimer.start()


func hang_around():
	if !ground_detect.is_colliding() or wall_detect.is_colliding():
		change_direction()
	speed = normal_speed


func change_direction():
	raycasts.scale.x = -raycasts.scale.x
	direction *= -1


func _on_detection_area_body_exited(body):
	if body.is_in_group("Player"):
		detecting_player = false

func _on_hit_box_body_entered(body):
	if body.is_in_group("Player"):
		player_is_inside_enemy = true
		body.take_damage()

func _on_hit_box_body_exited(body):
	if body.is_in_group("Player"):
		player_is_inside_enemy = false
