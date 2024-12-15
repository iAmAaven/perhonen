class_name Enemy

extends CharacterBody2D

@export var health: int
@export var max_health: int

@onready var timer = $Timer

var is_hurting = false
var taking_knockback = false


func take_damage(damage_to_take):
	if is_hurting:
		return
	
	is_hurting = true
	health -= damage_to_take
	if health <= 0:
		print_debug("Enemy died!")
		death()
	
	$HurtAnimation.play("hurt")
	
	timer.start(0.25)
	await timer.timeout
	
	is_hurting = false

func death():
	# TODO: Add death animation
	queue_free()
