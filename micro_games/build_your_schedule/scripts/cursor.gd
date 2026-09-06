extends Node2D
class_name BuildScheduleCursor

var prior_mouse_mode: int

func get_empty_texture() -> Texture:
	return preload("res://micro_games/build_your_schedule/empty.png")

func _ready() -> void:
	prior_mouse_mode = Input.get_mouse_mode()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	Input.set_custom_mouse_cursor(get_empty_texture(), Input.CURSOR_ARROW)
	Input.set_custom_mouse_cursor(get_empty_texture(), Input.CURSOR_POINTING_HAND)
	
func _process(_delta: float) -> void:
	global_position = get_global_mouse_position()
	var shape := Input.get_current_cursor_shape()
	$Default.visible = shape != Input.CURSOR_POINTING_HAND
	$Pointer.visible = shape == Input.CURSOR_POINTING_HAND
	
func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		Input.set_mouse_mode(prior_mouse_mode)
