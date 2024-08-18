extends RigidBody2D


@onready var player_detection = $PlayerDetection
@onready var hit_collider = $HitCollider

var has_fallen = false


func _ready():
	gravity_scale = 0

func _physics_process(delta):
	if player_detection.is_colliding():
		gravity_scale = 1
		await get_tree().create_timer(0.25).timeout
		has_fallen = true
	
	if has_fallen == true and linear_velocity == Vector2.ZERO:
		hit_collider.monitoring = false


func _on_hit_collider_body_entered(body):
	if body.is_in_group("Player") or body.is_in_group("Enemy"):
		body.take_damage(1)
		queue_free()
