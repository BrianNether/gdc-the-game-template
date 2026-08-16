@tool
extends Control
## Draws a dashed rectangular border around this Control's full rect -
## StyleBoxFlat has no dashed option.

@export var border_color: Color = Color(0.1882353, 0.1882353, 0.1882353, 1.0)
@export var border_width: float = 6.0
@export_range(1.0, 100.0) var dash_length: float = 14.0
@export_range(0.0, 100.0) var gap_length: float = 14.0
## Gap between each corner block and the nearest dash. 0 = flush.
@export_range(0.0, 100.0) var corner_gap: float = 0.0

## Toggle to force a redraw without reloading the scene.
@export var force_resync: bool = false:
	set(_value):
		_ensure_connected()
		queue_redraw()

var _connected := false


func _ready() -> void:
	_ensure_connected()
	queue_redraw()


func _ensure_connected() -> void:
	if not _connected:
		resized.connect(queue_redraw)
		_connected = true


func _draw() -> void:
	var hw := border_width * 0.5

	# draw_line()/draw_rect() center their stroke on the coordinate, so inset
	# by half the border width to keep the stroke inside the node's bounds
	# (matches uiborder.gdshader's convention)
	var rect := Rect2(Vector2(hw, hw), size - Vector2(border_width, border_width))

	# solid corner blocks avoid dash-phase mismatches between adjacent edges
	for corner in [rect.position, Vector2(rect.end.x, rect.position.y), rect.end, Vector2(rect.position.x, rect.end.y)]:
		draw_rect(Rect2(corner - Vector2(hw, hw), Vector2(border_width, border_width)), border_color)

	# Dashed edges, inset so they run only between the corner blocks.
	_dashed_edge(Vector2(rect.position.x + border_width, rect.position.y), Vector2(rect.end.x - border_width, rect.position.y))
	_dashed_edge(Vector2(rect.end.x, rect.position.y + border_width), Vector2(rect.end.x, rect.end.y - border_width))
	_dashed_edge(Vector2(rect.end.x - border_width, rect.end.y), Vector2(rect.position.x + border_width, rect.end.y))
	_dashed_edge(Vector2(rect.position.x, rect.end.y - border_width), Vector2(rect.position.x, rect.position.y + border_width))


## Justifies dashes along the edge (like text justification): fits as many
## fixed-width dashes as possible using gap_length as the target gap, then
## stretches the gaps evenly to fill the edge exactly.
func _dashed_edge(from: Vector2, to: Vector2) -> void:
	var offset := to - from
	var full_length := offset.length()
	if full_length <= 0.0 or dash_length <= 0.0:
		return
	var direction := offset / full_length

	var usable_length: float = full_length - corner_gap * 2.0
	if usable_length <= 0.0:
		return
	var start_offset := corner_gap

	if usable_length <= dash_length:
		# too short for even one dash + gap - draw one, centered
		var seg_len: float = minf(dash_length, usable_length)
		var start: float = start_offset + (usable_length - seg_len) * 0.5
		draw_line(from + direction * start, from + direction * (start + seg_len), border_color, border_width)
		return

	var step: float = dash_length + gap_length
	var dash_count: int = maxi(int(floor((usable_length + gap_length) / step)), 1)

	var adjusted_gap: float = gap_length
	if dash_count > 1:
		adjusted_gap = (usable_length - dash_count * dash_length) / float(dash_count - 1)

	var pos := start_offset
	for i in range(dash_count):
		draw_line(from + direction * pos, from + direction * (pos + dash_length), border_color, border_width)
		pos += dash_length + adjusted_gap
