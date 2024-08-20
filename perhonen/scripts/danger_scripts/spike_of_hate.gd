extends CharacterBody2D


@export var speed: int

@onready var player_detection = $PlayerDetection
@onready var hit_collider = $HitCollider

var has_fallen = false


func _physics_process(delta):
	if player_detection.is_colliding():
		var max_speed = speed * delta * 1000
		velocity.y = move_toward(velocity.y, max_speed, 200)
		has_fallen = true
	
	if has_fallen and velocity.y == 0:
		hit_collider.monitoring = false
	
	move_and_slide()


func _on_hit_collider_body_entered(body):
	if body.is_in_group("Player"):
		body.take_damage(5, true)
	elif body.is_in_group("Enemy"):
		body.take_damage(1)
		
