extends Enemy


@onready var wall_detect = $Raycasts/WallDetect
@onready var graphics = $Graphics
@onready var raycasts = $Raycasts

@export var speed: int

var direction = -1



func _physics_process(delta):
	if !wall_detect.is_colliding():
		velocity.x = speed * direction
	else:
		velocity.x = 0
		change_direction()
	
	if velocity.x < 0:
		graphics.flip_h = false
	elif velocity.x > 0:
		graphics.flip_h = true
	
	move_and_slide()


func change_direction():
	raycasts.scale.x = -raycasts.scale.x
	direction *= -1


func _on_hit_box_body_entered(body):
	if body.is_in_group("Player"):
		body.take_damage()
