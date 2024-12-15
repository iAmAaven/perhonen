extends CanvasLayer

@export_group("Health Graphics")
@export var one_hp: Array
@export var two_hp: Array
@export var three_hp: Array
@export var four_hp: Array


var current_max_health: int
var current_health: int


@onready var hp = $HP


func _ready():

	update_health()

func update_health():
	current_health = PlayerTracker.health
	current_max_health = PlayerTracker.max_health
	
	match current_max_health:
		1:
			choose_graphics(one_hp)
		2:
			choose_graphics(two_hp)
		3:
			choose_graphics(three_hp)
		4:
			choose_graphics(four_hp)


func choose_graphics(hp_array):
	hp.texture = hp_array[hp_array.size() - current_health - 1]
