extends Control
class_name MicroGameTransition

@onready var mouse_only_input = %mouse_only_input
@onready var keyboard_only_input = %keyboard_only_input
@onready var keyboard_and_mouse_input = %keyboard_and_mouse_input
@onready var description = %description
@onready var score_number : DigitDisplay = %score_number
@onready var lives_display : TextureRect = %lives_display

@export var life_frames : Array[Texture2D]

func _ready() -> void:
	hide_all()
	#play_animation("This is a test!", keyboard_and_mouse_input)

func hide_all():
	mouse_only_input.visible = false
	keyboard_only_input.visible = false
	keyboard_and_mouse_input.visible = false
	description.visible = false
	
	
func play_animation(description_text, inp : Control):
	hide_all()
	
	inp.scale = Vector2(0.1, 0.1)
	inp.visible = true
	
	description.visible = true
	description.visible_ratio = 0
	description.text = description_text
	
	var tween = create_tween()
	tween.parallel().tween_property(inp, "scale", Vector2.ONE, 0.5)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(description, "visible_ratio", 1, 0.25)
	
	tween.chain().tween_interval(2.5)
	
	await tween.finished
	
	hide_all()
	
@onready var animator = $AnimationPlayer
func update_score(new_val : int):
	animator.play("score_slide_in")
	await animator.animation_finished
	await get_tree().create_timer(0.3).timeout

	var tween = create_tween()
	tween.tween_property(score_number, "scale", Vector2(1.1, 1.1), 0.1)\
		.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	tween.tween_callback(score_number.set_number.bind(new_val))
	tween.tween_property(score_number, "scale", Vector2.ONE, 0.1)\
		.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	
	await tween.finished

func update_lives(new_val : int):
	lives_display
	
