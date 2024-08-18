extends Area2D


@export var respawn_point_left: Vector2
@export var respawn_point_right: Vector2


func _on_body_entered(body):
	if body.is_in_group("Player"):
		body.take_damage(5, true)
		if body.is_dead == false:
			if PlayerTracker.last_door_entered == "Left":
				body.position = respawn_point_right
			else:
				body.position = respawn_point_left
			
			body.graphics.play("idle_R")
			PlayerTracker.can_move = false
			await get_tree().create_timer(0.75).timeout
			PlayerTracker.can_move = true
