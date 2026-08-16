@tool
extends BaseButton
class_name PixelButton

const GameSFX = preload("res://micro_games/midnight_deadline/Scripts/game_sfx.gd")

## Custom-drawn button: solid fill with pixel-art "stairstep" corners, a
## light outline on hover, grey when disabled. Extends BaseButton (not
## Button) so nothing draws a StyleBox underneath our own _draw(); text is a
## managed child Label so it still draws on top.

@export var button_text: String = "SUBMIT":
	set(value):
		button_text = value
		if _label:
			_label.text = value

@export var font: Font:
	set(value):
		font = value
		_ensure_label()
		if font:
			_label.add_theme_font_override("font", font)

@export var font_size: int = 14:
	set(value):
		font_size = value
		_ensure_label()
		_label.add_theme_font_size_override("font_size", font_size)

@export_group("Colors")
@export var fill_color: Color = Color(0.20392157, 0.49411765, 0.8235294, 1.0)
@export var hover_color: Color = Color(0.14, 0.37, 0.63, 1.0)
@export var hover_outline_color: Color = Color(0.61, 0.8, 0.95, 1.0)
@export var disabled_color: Color = Color(0.5411765, 0.5411765, 0.5411765, 1.0)
@export var text_color: Color = Color(1, 1, 1, 1)
@export var disabled_text_color: Color = Color(0.78, 0.78, 0.78, 1.0)

@export_group("Shape")
@export_range(1.0, 40.0) var corner_step_size: float = 10.0
@export_range(1, 5) var corner_steps: int = 2
@export var outline_width: float = 10.0

## _ready() doesn't refire when this script/its props change on an
## already-open node - toggle to force a refresh without reloading the scene.
@export_group("")
@export var force_resync: bool = false:
	set(_value):
		_ensure_label()
		_ensure_connected()
		queue_redraw()

var _label: Label
var _connected := false
var _last_disabled := false
var _press_tween: Tween


func _ready() -> void:
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_ensure_label()
	_ensure_connected()
	_last_disabled = disabled
	set_process(true)
	pivot_offset = size * 0.5
	resized.connect(func(): pivot_offset = size * 0.5)
	queue_redraw()


func _process(_delta: float) -> void:
	# `disabled` has no changed-signal, so poll for it
	if disabled != _last_disabled:
		_last_disabled = disabled
		queue_redraw()


func _ensure_connected() -> void:
	if not _connected:
		resized.connect(queue_redraw)
		mouse_entered.connect(queue_redraw)
		mouse_exited.connect(queue_redraw)
		mouse_entered.connect(_on_hover_enter)
		pressed.connect(_on_pressed)
		_connected = true


func _on_hover_enter() -> void:
	if disabled or Engine.is_editor_hint():
		return
	GameSFX.play(self, "res://micro_games/midnight_deadline/Assets/hover.wav", -8.0)


## Squash-then-bounce on press.
func _on_pressed() -> void:
	if Engine.is_editor_hint():
		return
	GameSFX.play(self, "res://micro_games/midnight_deadline/Assets/softclick.wav", -4.0)
	if _press_tween and _press_tween.is_valid():
		_press_tween.kill()
	scale = Vector2(0.92, 0.88)
	_press_tween = create_tween()
	_press_tween.tween_property(self, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _ensure_label() -> void:
	if _label == null:
		_label = get_node_or_null("Label") as Label
	if _label == null:
		_label = Label.new()
		_label.name = "Label"
		_label.set_anchors_preset(Control.PRESET_FULL_RECT)
		_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(_label)
		if Engine.is_editor_hint() and is_inside_tree():
			_label.owner = get_tree().edited_scene_root
	_label.text = button_text
	if font:
		_label.add_theme_font_override("font", font)
	_label.add_theme_font_size_override("font_size", font_size)


func _draw() -> void:
	_ensure_label()
	var color := disabled_color if disabled else (hover_color if is_hovered() else fill_color)
	_label.add_theme_color_override("font_color", disabled_text_color if disabled else text_color)

	# outer-only outline: draw an inflated copy of the shape underneath, then
	# the normal fill on top - only the uncovered outer band stays visible
	if is_hovered() and not disabled:
		var outer_rect := Rect2(-Vector2.ONE * outline_width, size + Vector2.ONE * outline_width * 2.0)
		draw_colored_polygon(_stairstep_polygon(outer_rect), hover_outline_color)

	draw_colored_polygon(_stairstep_polygon(Rect2(Vector2.ZERO, size)), color)


## The button's rect with each corner cut into a blocky staircase instead
## of a smooth rounded arc.
func _stairstep_polygon(rect: Rect2) -> PackedVector2Array:
	var poly := PackedVector2Array()
	poly.append_array(_reversed(_stairstep_corner(rect.position, 1.0, 1.0)))
	poly.append_array(_stairstep_corner(Vector2(rect.end.x, rect.position.y), -1.0, 1.0))
	poly.append_array(_reversed(_stairstep_corner(rect.end, -1.0, -1.0)))
	poly.append_array(_stairstep_corner(Vector2(rect.position.x, rect.end.y), 1.0, -1.0))
	return poly


## One corner's staircase points; dx_sign/dy_sign point toward the interior.
func _stairstep_corner(corner: Vector2, dx_sign: float, dy_sign: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	var x: float = corner.x + dx_sign * corner_steps * corner_step_size
	var y: float = corner.y
	pts.append(Vector2(x, y))
	for i in range(corner_steps):
		y += dy_sign * corner_step_size
		pts.append(Vector2(x, y))
		x -= dx_sign * corner_step_size
		pts.append(Vector2(x, y))
	return pts


func _reversed(arr: PackedVector2Array) -> PackedVector2Array:
	var out := PackedVector2Array()
	for i in range(arr.size() - 1, -1, -1):
		out.append(arr[i])
	return out
