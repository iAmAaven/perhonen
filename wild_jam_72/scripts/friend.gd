extends Node2D


var follow_speed = 8.5
var player: Node2D = null
var target: Vector2

func _ready():
	player = get_tree().get_first_node_in_group("Player")

func _physics_process(delta):
	if player != null:
		if player.going_right == true:
			target.x = player.position.x - 80
		else:
			target.x = player.position.x + 80
		
		target.y = player.position.y - 150
		position = position.move_toward(target, follow_speed)
