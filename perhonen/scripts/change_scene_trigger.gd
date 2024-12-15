extends Area2D


@export var scene_to_load: String
@export var door_location: String # Up, Down, Left, Right
@onready var timer = $Timer


func _ready():
	load(scene_to_load)

func _on_body_entered(body):
	if scene_to_load != null and body.is_in_group("Player"):
		PlayerTracker.last_door_entered = door_location
		PlayerTracker.able_to_move = false
		Fades.play_animation("fade_in")
		
		timer.start(1)
		await timer.timeout
		
		get_tree().change_scene_to_file(scene_to_load)
