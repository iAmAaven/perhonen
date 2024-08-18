extends StaticBody2D


@export var needed_key: String


func _ready():
	if DoorsUnlockedData.doors_opened.has(needed_key):
		queue_free()

func _on_unlock_trigger_body_entered(body):
	if DoorsUnlockedData.keys_gotten.has(needed_key):
		if !DoorsUnlockedData.doors_opened.has(needed_key):
			DoorsUnlockedData.doors_opened.append(needed_key)
		$OpenAnimation.play("open")
	else:
		$OpenAnimation.play("locked")
