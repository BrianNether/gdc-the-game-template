extends Control

@onready var mouse_only_input = %mouse_only_input
@onready var keyboard_only_input = %keyboard_only_input
@onready var keyboard_and_mouse_input = %keyboard_and_mouse_input

@onready var description = %description

func hide_all():
	mouse_only_input.visible = false
	keyboard_only_input.visible = false
	keyboard_and_mouse_input.visible = false
	description.visible = false

func _ready() -> void:
	hide_all()


func display_controls(info : MicroGameInfo):
	if info.control_format == MicroGame.ControlFormat.MouseOnly:
		await play_controls(info.instruction, mouse_only_input)
		
	elif info.control_format == MicroGame.ControlFormat.KeyboardOnly:
		await play_controls(info.instruction, keyboard_only_input)
		
	else:
		await play_controls(info.instruction, keyboard_and_mouse_input)

func play_controls(description_text, inp : Control):
	hide_all()
	await pop_in(inp, Vector2(5.0, 5.0))
	await get_tree().create_timer(0.7).timeout
	description.text = description_text
	await pop_in(description, Vector2(0.1, 0.1))
	
func pop_in(inp : Control, start_at : Vector2):
	var original_scale = inp.scale
	inp.scale = start_at
	inp.visible = true
	
	var tween = create_tween()
	tween.tween_property(inp, "scale", original_scale, 0.25)\
		.set_trans(Tween.TRANS_EXPO)
	await tween.finished
