extends Area2D

var ui

func _ready():
	ui = get_tree().get_first_node_in_group("UI")

func _on_body_entered(body):
	if body.is_in_group("Player") and PlayerTracker.health < PlayerTracker.max_health:
		PlayerTracker.health += 5
		if PlayerTracker.health > PlayerTracker.max_health:
			PlayerTracker.health = PlayerTracker.max_health
		ui.update_health()
		queue_free()
