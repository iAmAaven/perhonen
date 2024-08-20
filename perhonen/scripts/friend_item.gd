extends Area2D


@export var damage_after_picking_up: int

var friend = preload("res://scenes/friend.tscn")


func _ready():
	if PlayerTracker.player_damage >= damage_after_picking_up:
		queue_free()
	


func _on_body_entered(body):
	if body.is_in_group("Player"):
		PlayerTracker.player_damage = damage_after_picking_up
		
		var instance = friend.instantiate()
		if instance != null:
			instance.position = body.position
			get_tree().current_scene.call_deferred("add_child", instance)
			queue_free()
	
