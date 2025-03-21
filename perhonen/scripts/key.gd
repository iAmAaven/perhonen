extends Area2D

@export var key_name: String
@export var is_memory_required: bool
@export var memory_required: String


func _ready():
	if DoorsUnlockedData.keys_gotten.has(key_name):
		queue_free()
	else:
		if is_memory_required and !DoorsUnlockedData.memories_watched.has(memory_required):
			queue_free()

func _on_body_entered(body):
	if body.is_in_group("Player"):
		DoorsUnlockedData.keys_gotten.append(key_name)
		queue_free()
	
