extends Area2D
class_name FindASeatEmptySeat

signal clicked

func _input_event(_viewport: Viewport, event: InputEvent, _shape_index: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		clicked.emit()
