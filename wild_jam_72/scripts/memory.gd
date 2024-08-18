extends Node2D


@export var room_to_transition_to: String
@export var entrance_in_room: String


func _ready():
	Fades.play_animation("fade_out")


func go_back():
	PlayerTracker.last_door_entered = entrance_in_room
	get_tree().change_scene_to_file(room_to_transition_to)
