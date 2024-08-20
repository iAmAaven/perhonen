extends Node


var last_door_entered: String
var last_checkpoint: String
var health = 50
var max_health = 50
var player_damage: int = 1

var can_move = true


func block_movement():
	can_move = false

func enable_movement():
	can_move = true
