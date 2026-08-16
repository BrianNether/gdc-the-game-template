extends AnimationPlayer

func _ready() -> void:
	print("running annimation")
	print(get_animation_list()[1])
	play(get_animation_list()[1])
