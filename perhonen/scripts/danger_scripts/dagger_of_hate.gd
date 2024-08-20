extends CharacterBody2D


@onready var hit_collider = $HitCollider

var direction: Vector2
var speed: int = 40


func _physics_process(delta):
	velocity = direction * speed * delta * 1000
	move_and_slide()


func _on_hit_collider_body_entered(body):
	if body.is_in_group("Player") and hit_collider.monitoring:
		body.take_damage(5, true)
		queue_free()
	else:
		hit_collider.set_deferred("monitoring", false)
		speed = 0
