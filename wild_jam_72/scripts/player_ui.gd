extends CanvasLayer


@onready var health_bar = $HealthBar


func _ready():
	health_bar.max_value = PlayerTracker.max_health
	health_bar.value = PlayerTracker.health


func update_health():
	health_bar.value = PlayerTracker.health
