extends Node2D


func _ready():
	PlayerTracker.last_checkpoint = get_tree().current_scene.scene_file_path
