extends Node2D
class_name FindASeatEmptySeat

signal clicked

func _ready() -> void:
	$Button.pressed.connect(clicked.emit)
