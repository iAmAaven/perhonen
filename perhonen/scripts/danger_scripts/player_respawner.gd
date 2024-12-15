extends Area2D


@export var respawn_point: Vector2
@onready var timer = $Timer


func _on_body_entered(body):
	if body.is_in_group("Player"):
		body.take_damage()
		
		timer.start(1)
		await timer.timeout
		
		body.position = respawn_point
