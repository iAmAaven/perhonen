extends Area2D


@export var respawn_point_left: Vector2
@export var respawn_point_right: Vector2


func _on_body_entered(body):
	if body.is_in_group("Player"):
		body.take_damage(1)
		if body.is_dead == false:
			if PlayerTracker.last_door_entered == "Left":
				body.position = respawn_point_right
			else:
				body.position = respawn_point_left
