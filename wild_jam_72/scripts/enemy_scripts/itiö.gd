extends Enemy


@onready var player_detect = $PlayerDetect
@onready var wall_detect = $Raycasts/WallDetect
@onready var graphics = $Graphics
@onready var raycasts = $Raycasts

@export var speed: int
@export var attack_rate: int = 3

var dagger_of_hate = preload("res://scenes/dangers/dagger_of_hate.tscn")
var player: Node2D = null
var can_see_player = false
var is_attacking = false
var direction = -1
var can_attack = true
var player_in_range = false


func _ready():
	player = get_tree().get_first_node_in_group("Player")

func _physics_process(delta):
	if !wall_detect.is_colliding():
		if !is_attacking:
			velocity.x = speed * direction
	else:
		velocity.x = 0
		change_direction()
	
	line_of_sight()
	
	if can_see_player and player_in_range:
		if can_attack:
			throw_dagger()
		if player != null:
			if player.position.x < position.x:
				graphics.flip_h = false
			elif player.position.x > position.x:
				graphics.flip_h = true
	else:
		if velocity.x < 0:
			graphics.flip_h = false
		elif velocity.x > 0:
			graphics.flip_h = true
	
	move_and_slide()


func change_direction():
	raycasts.scale.x = -raycasts.scale.x
	direction *= -1


func throw_dagger():
	print_debug("Threw dagger")
	if player != null:
		can_attack = false
		is_attacking = true
		velocity.x = 0
		
		await get_tree().create_timer(0.5).timeout
		
		var attack_direction = player.global_position - global_position
		attack_direction = attack_direction.normalized()
		var instance = dagger_of_hate.instantiate()
		if instance:
			instance.position = graphics.global_position
			instance.direction = attack_direction
			var rot_direction = player.global_position - instance.global_position
			var angle = atan2(rot_direction.y, rot_direction.x)
			instance.rotation = angle
			get_tree().current_scene.add_child(instance)
		
		await get_tree().create_timer(0.5).timeout
		is_attacking = false
		await get_tree().create_timer(attack_rate - 0.5).timeout
		can_attack = true


func line_of_sight():
	if player == null:
		return
	
	var rayDirection = player.global_position - global_position
	player_detect.target_position = rayDirection
	player_detect.force_raycast_update()
	
	if player_detect.is_colliding():
		var collider = player_detect.get_collider()
		
		if collider == player:
			can_see_player = true
		else:
			can_see_player = false
	else:
		can_see_player = false


func _on_player_in_range_body_entered(body):
	if body.is_in_group("Player"):
		player_in_range = true

func _on_player_in_range_body_exited(body):
	if body.is_in_group("Player"):
		player_in_range = false


func _on_hit_box_body_entered(body):
	if body.is_in_group("Player"):
		body.take_damage(damage, true)
