extends Control


@onready var fade_animations = $FadeAnimations


func _on_play_pressed():
	fade_animations.play("fade_in")
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_file("res://scenes/memories/opening_scene.tscn")
