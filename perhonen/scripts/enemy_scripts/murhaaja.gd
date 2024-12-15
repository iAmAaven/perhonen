extends Enemy


@onready var raycasts = $Raycasts
@onready var ground_detect = $Raycasts/GroundDetect
@onready var wall_detect = $Raycasts/WallDetect
@onready var graphics = $Graphics
@onready var attack_area = $AttackArea
@onready var attack_timer = $Timer


var speed : int = 50

var direction: int = -1
var detecting_player = false
var player_is_inside_enemy = false
var is_attacking = false
var can_attack = true

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	if ground_detect.is_colliding() and !wall_detect.is_colliding():
		if !is_attacking:
			velocity.x = speed * direction
	else:
		velocity.x = 0
		change_direction()
	
	velocity.y += gravity * delta * 3
	
	if velocity.x < 0:
		graphics.flip_h = false
	elif velocity.x > 0:
		graphics.flip_h = true
	
	move_and_slide()


func change_direction():
	raycasts.scale.x = -raycasts.scale.x
	direction *= -1


func attack():
	is_attacking = true
	can_attack = false
	velocity.x = 0
	graphics.play("attack")
	
	attack_timer.start(0.75)
	await attack_timer.timeout
	
	attack_area.monitoring = true
	
	attack_timer.start(0.25)
	await attack_timer.timeout	
	
	attack_area.monitoring = false
	
	attack_timer.start(0.25)
	await attack_timer.timeout
	
	graphics.play("default")
	is_attacking = false
	
	attack_timer.start(0.75)
	await attack_timer.timeout
	
	can_attack = true


func _on_detection_area_body_entered(body):
	if body.is_in_group("Player"):
		if is_attacking == false and can_attack:
			attack()
		detecting_player = true

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

func _on_attack_area_body_entered(body):
	if body.is_in_group("Player"):
		body.take_damage()
