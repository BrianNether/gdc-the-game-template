extends Control

@export var life_frames : Array[Texture2D]

@onready var lives_display : Sprite2D = %lives_display

func _ready() -> void:
	await animate_value_change(3, 2)

func set_lives_sprite(idx):
	lives_display.texture = life_frames[idx]

func animate_value_change(old_val : int, new_val : int):
	set_lives_sprite(old_val)
	
	var original_scale = lives_display.scale
	
	var tween = create_tween()
	tween.tween_property(lives_display, "scale", original_scale * Vector2(1.25, 1.25), 0.25)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_callback(set_lives_sprite.bind(new_val))
	tween.tween_property(lives_display, "scale", original_scale, 0.1)\
		.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	
	await tween.finished
