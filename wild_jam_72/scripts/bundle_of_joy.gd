extends Area2D



func _on_body_entered(body):
	if body.is_in_group("Player") and PlayerTracker.health < PlayerTracker.max_health:
		PlayerTracker.health += 1
		print("Player healed. Current HP: " + str(PlayerTracker.health))
		queue_free()
