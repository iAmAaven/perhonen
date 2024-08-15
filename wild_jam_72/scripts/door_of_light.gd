extends StaticBody2D


@onready var animation_player = $AnimationPlayer
var is_door_open = false


func _on_trigger_body_entered(body):
	if body.is_in_group("Player") and !is_door_open:
		animation_player.play("door_open")
		is_door_open = true
