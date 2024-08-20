extends StaticBody2D


@export var memory_path: String
@export var memory_name: String


@onready var timer = $Timer


var is_transitioning = false
var player_detected = false


func _process(delta):
	if player_detected and Input.is_action_just_pressed("interact") and !is_transitioning:
		remember()

func _on_trigger_area_body_entered(body):
	if body.is_in_group("Player"):
		player_detected = true
		$RememberText.visible = true


func _on_trigger_area_body_exited(body):
	if body.is_in_group("Player"):
		player_detected = false
		$RememberText.visible = false


func remember():
	Fades.play_animation("fade_in")
	if !DoorsUnlockedData.memories_watched.has(memory_name):
		DoorsUnlockedData.memories_watched.append(memory_name)
	is_transitioning = true
	PlayerTracker.health = PlayerTracker.max_health
	PlayerTracker.last_checkpoint = get_tree().current_scene.scene_file_path
	
	timer.start(1)
	await timer.timeout
	
	get_tree().change_scene_to_file(memory_path)
