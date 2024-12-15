class_name Danger

extends Area2D


@export var damage: int


func _on_body_entered(body):
	if body.is_in_group("Player"):
		body.take_damage()
