extends StaticBody2D


@onready var animation_player = $AnimationPlayer
var is_door_open = false


func _ready():
	if DoorsUnlockedData.light_door_opened:
		queue_free()

func _on_trigger_body_entered(body):
	if body.is_in_group("Player") and !is_door_open:
		animation_player.play("door_open")
		is_door_open = true
		DoorsUnlockedData.light_door_opened = true
