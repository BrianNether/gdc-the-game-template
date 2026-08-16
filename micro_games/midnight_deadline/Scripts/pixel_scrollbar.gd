@tool
extends VScrollBar
## Custom-drawn scrollbar - track/thumb styleboxes cleared to empty since
## there's no theme-only way to make the thumb wider than the track, both
## rects hand-drawn instead. Grabber is a fixed length, not proportional to
## page/max_value, for a snappier feel.
##
## Not meant to be attached directly - scroll_style.gd swaps it onto the
## real v-scrollbar at runtime via set_script() and calls setup().

@export var track_color: Color = Color(1.0, 1.0, 1.0, 1.0)
@export var track_width: float = 10.0
@export var thumb_color: Color = Color(0.62352943, 0.62352943, 0.62352943, 1.0)
@export var thumb_width: float = 20.0
@export var grabber_length: float = 120.0

var _connected := false


func _ready() -> void:
	setup()


func setup() -> void:
	custom_minimum_size.x = maxf(track_width, thumb_width)
	var empty := StyleBoxEmpty.new()
	add_theme_stylebox_override("scroll", empty)
	add_theme_stylebox_override("grabber", empty)
	add_theme_stylebox_override("grabber_highlight", empty)
	add_theme_stylebox_override("grabber_pressed", empty)
	if not _connected:
		changed.connect(queue_redraw)
		value_changed.connect(func(_v): queue_redraw())
		resized.connect(queue_redraw)
		_connected = true
	queue_redraw()


func _draw() -> void:
	var h := size.y
	var w := size.x

	draw_rect(Rect2((w - track_width) * 0.5, 0, track_width, h), track_color)

	var thumb_height: float = minf(grabber_length, h)
	var scroll_range: float = max_value - page
	var value_ratio: float = 0.0 if scroll_range <= 0.0 else clampf(value / scroll_range, 0.0, 1.0)
	var thumb_y: float = value_ratio * (h - thumb_height)

	draw_rect(Rect2((w - thumb_width) * 0.5, thumb_y, thumb_width, thumb_height), thumb_color)
