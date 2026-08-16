@tool
extends Control
class_name FileEntry

const GameSFX = preload("res://micro_games/midnight_deadline/Scripts/game_sfx.gd")

## Reusable file-explorer icon: an icon texture + caption. Populated and
## shuffled into place by file_explorer_grid.gd. Every entry is draggable;
## only `is_correct_file` tells the real one apart, so submitting the wrong
## one is possible (and loses). Expects two children: "Thumb" (TextureRect)
## and "Caption" (Label).

@export var draggable := false:
	set(value):
		draggable = value
		mouse_filter = Control.MOUSE_FILTER_PASS if value else Control.MOUSE_FILTER_IGNORE
		mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if value else Control.CURSOR_ARROW

@export var drag_payload_type := "submit_file"
## Whether this is the actual file the player is supposed to submit.
@export var is_correct_file := false

@export var icon_texture: Texture2D:
	set(value):
		icon_texture = value
		if _thumb:
			_thumb.texture = value

@export var caption_text: String = "":
	set(value):
		caption_text = value
		if _caption:
			_caption.text = value

@onready var _thumb: TextureRect = $Thumb
@onready var _caption: Label = $Caption

var _hover_tween: Tween


func _ready() -> void:
	_thumb.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_thumb.stretch_mode = TextureRect.STRETCH_SCALE
	if icon_texture:
		_thumb.texture = icon_texture
	if caption_text != "":
		_caption.text = caption_text
	mouse_filter = Control.MOUSE_FILTER_PASS if draggable else Control.MOUSE_FILTER_IGNORE
	pivot_offset = size * 0.5
	resized.connect(func(): pivot_offset = size * 0.5)
	if not mouse_entered.is_connected(_on_hover_enter):
		mouse_entered.connect(_on_hover_enter)
		mouse_exited.connect(_on_hover_exit)


func _on_hover_enter() -> void:
	if not draggable or Engine.is_editor_hint():
		return
	_tween_scale(Vector2(1.05, 1.05), 0.1)
	GameSFX.play(self, "res://micro_games/midnight_deadline/Assets/hover.wav", -10.0)


func _on_hover_exit() -> void:
	if Engine.is_editor_hint():
		return
	_tween_scale(Vector2.ONE, 0.12)


func _tween_scale(target: Vector2, duration: float) -> void:
	if _hover_tween and _hover_tween.is_valid():
		_hover_tween.kill()
	_hover_tween = create_tween()
	_hover_tween.tween_property(self, "scale", target, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END and not Engine.is_editor_hint():
		_tween_scale(Vector2.ONE, 0.12)
		modulate.a = 1.0


func _get_drag_data(_at_position: Vector2):
	if not draggable:
		return null

	var preview := Control.new()
	preview.size = size
	preview.modulate.a = 0.85
	for child in get_children():
		var dup: Node = child.duplicate()
		preview.add_child(dup)

	# -size*0.5 centers the preview on the cursor; the rest is a manual nudge
	preview.position = -size * 0.5 + Vector2(-20, -20)
	var wrapper := Control.new()
	wrapper.add_child(preview)
	set_drag_preview(wrapper)

	modulate.a = 0.4
	GameSFX.play(self, "res://micro_games/midnight_deadline/Assets/softclick.wav", -14.0)

	return {"type": drag_payload_type, "is_correct": is_correct_file, "name": caption_text}
