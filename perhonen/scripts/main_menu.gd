extends Control


@onready var fade_animations = $FadeAnimations
@onready var timer = $Timer


func _on_play_pressed():
	fade_animations.play("fade_in")
	
	timer.start(1)
	await timer.timeout
	
	get_tree().change_scene_to_file("res://scenes/memories/opening_scene.tscn")
