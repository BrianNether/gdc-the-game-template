extends Control
class_name MicroGameTransition

@onready var mouse_only_input = %mouse_only_input
@onready var keyboard_only_input = %keyboard_only_input
@onready var keyboard_and_mouse_input = %keyboard_and_mouse_input
@onready var description = %description
@onready var score_number : DigitDisplay = %score_number
@onready var lives_display : Sprite2D = %lives_display

@export var life_frames : Array[Texture2D]


func _ready() -> void:
	hide_all()
	#update_lives(2, 3)
	#play_animation("This is a test!", keyboard_and_mouse_input)

func hide_all():
	mouse_only_input.visible = false
	keyboard_only_input.visible = false
	keyboard_and_mouse_input.visible = false
	description.get_parent().visible = false
	description.visible = true
	lives_display.visible = false
	
func display_controls(info : MicroGameInfo):
	if info.control_format == MicroGame.ControlFormat.MouseOnly:
		await play_controls(info.description, mouse_only_input)
		
	elif info.control_format == MicroGame.ControlFormat.KeyboardOnly:
		await play_controls(info.description, keyboard_only_input)
		
	else:
		await play_controls(info.description, keyboard_and_mouse_input)

func play_controls(description_text, inp : Control):
	hide_all()
	
	inp.scale = Vector2(0.1, 0.1)
	inp.visible = true
	
	description.get_parent().visible = false
	description.visible = true
	description.visible_ratio = 0
	description.text = description_text
	
	var tween = create_tween()
	tween.tween_property(inp, "scale", Vector2.ONE, 0.3)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_interval(0.4)
	tween.tween_property(description.get_parent(), "visible", true, 0)
	tween.tween_property(description, "visible_ratio", 1, 0.25)
	
	tween.tween_interval(1.5)
	print(tween.get_loops_left())
	await tween.finished
	
	hide_all()
	
@onready var animator = $AnimationPlayer
func update_score(new_val : int, old_val : int):
	score_number.set_number(old_val)
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
	await get_tree().create_timer(1).timeout
	
	animator.play("score_slide_out")
	await animator.animation_finished

var next_sprite = 0
func set_lives_sprite():
	lives_display.texture = life_frames[next_sprite]

func update_lives(new_val : int, old_val : int):
	hide_all()
	lives_display.texture = life_frames[old_val]
	lives_display.visible = true
	
	animator.play("life_pop_in")
	await animator.animation_finished
	
	await get_tree().create_timer(0.3).timeout

	next_sprite = new_val
	animator.play("life_bite")
	await animator.animation_finished

	await get_tree().create_timer(0.8).timeout
	
	animator.play("life_pop_out")
	await animator.animation_finished
	
	hide_all()
	
