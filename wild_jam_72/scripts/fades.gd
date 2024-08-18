extends CanvasLayer


@onready var fade_animations = $FadeAnimations


func play_animation(name_of_animation):
	fade_animations.play(name_of_animation)
