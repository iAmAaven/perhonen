extends Node


# Room navigation data
var last_door_entered: String
var last_checkpoint: String

# Player data
var health = 4
var max_health = 4
var player_damage: int = 1

# Ability data
var can_slice := false
var can_dash := false
var can_slice_down := false
var can_levitate := false

# Can be used to disable player movement during cutscene animations
var able_to_move = true


# Can be called to disable player movement
func block_movement():
	able_to_move = false

func enable_movement():
	able_to_move = true
