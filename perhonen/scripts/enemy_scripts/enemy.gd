class_name Enemy

extends CharacterBody2D

@export var health: int
@export var max_health: int
@export var damage: int

@onready var timer = $Timer

var is_hurting = false
var taking_knockback = false

var healing_item = preload("res://scenes/items/bundle_of_joy.tscn")


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
	var random_chance = randf_range(0, 1)
	if random_chance < 0.1:
		var instance = healing_item.instantiate()
		if instance != null:
			instance.global_position = global_position
			get_tree().current_scene.call_deferred("add_child", instance)
	
	queue_free()