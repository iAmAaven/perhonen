extends Node2D


var player: Node2D = null
@export var entrance_up: Vector2
@export var entrance_down: Vector2
@export var entrance_left: Vector2
@export var entrance_right: Vector2


func _ready():
	player = get_tree().get_first_node_in_group("Player")
	if player != null:
		var last_door = PlayerTracker.last_door_entered
		match last_door:
			"Up":
				player.position = entrance_down
			"Down":
				player.position = entrance_up
			"Left":
				player.position = entrance_right
				player.going_right = false
			"Right":
				player.position = entrance_left
				player.going_right = true
