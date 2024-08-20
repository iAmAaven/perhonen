extends Node2D


func _ready():
	Fades.play_animation("fade_out")
	PlayerTracker.last_checkpoint = get_tree().current_scene.scene_file_path
