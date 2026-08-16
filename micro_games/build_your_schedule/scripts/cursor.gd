extends Node2D
class_name BuildScheduleCursor

var prior_mouse_mode: int

func _ready() -> void:
	prior_mouse_mode = Input.get_mouse_mode()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
func _process(_delta: float) -> void:
	global_position = get_global_mouse_position()
	var shape := Input.get_current_cursor_shape()
	$Default.visible = shape != Input.CURSOR_POINTING_HAND
	$Pointer.visible = shape == Input.CURSOR_POINTING_HAND
	
func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		Input.set_mouse_mode(prior_mouse_mode)
