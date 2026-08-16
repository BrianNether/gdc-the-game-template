extends ColorRect
class_name BuildScheduleCourse

signal clicked

@export var clickable := true
@export var faded := false
var days: Array
var style: int
var associated_course: BuildScheduleCourse
var associated_day: int
var tween: Tween

const DAY_NAMES: Array[String] = ["MON", "TUE", "WED", "THU", "FRI"]
const STYLE_COUNT: int = 5
const STYLE_COLORS: Array[Color] = [
	Color("962f2fff"),
	Color("2f9396ff"),
	Color("2f963cff"),
	Color("96722fff"),
	Color("742f96ff"),
]
const STYLE_ICONS: Array[Texture2D] = [
	preload("res://micro_games/build_your_schedule/assets/circle.png"),
	preload("res://micro_games/build_your_schedule/assets/diamond.png"),
	preload("res://micro_games/build_your_schedule/assets/square.png"),
	preload("res://micro_games/build_your_schedule/assets/star.png"),
	preload("res://micro_games/build_your_schedule/assets/triangle.png"),
]
const BASE_SIZE = Vector2(384, 128)

func set_clickable(value: bool) -> void:
	clickable = value
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if clickable else Control.CURSOR_ARROW
	%Shadow.visible = clickable and not faded
	
func set_faded(value: bool) -> void:
	faded = value
	%Background.color = Color(0.235, 0.25, 0.25, 1.0) if faded else STYLE_COLORS[style]
	modulate.a = 0.5 if faded else 1.0
	%Shadow.visible = clickable and not faded

func set_style(new_style: int) -> void:
	style = new_style
	%Background.color = STYLE_COLORS[style]
	%Icon.texture = STYLE_ICONS[style]

func set_days(new_days: Array) -> void:
	days = new_days
	%Label.text = ""
	for i in range(len(DAY_NAMES)):
		if i in days: %Label.text += DAY_NAMES[i] + "\n"
	%Label.text = %Label.text.trim_suffix("\n")
	
func grow_in() -> void:
	await get_tree().process_frame
	if tween: tween.kill()
	tween = create_tween().set_trans(Tween.TRANS_QUAD)
	scale = Vector2.ZERO
	tween.set_ease(Tween.EASE_OUT).tween_property(self, "scale", Vector2.ONE * 1.2, 0.2)
	tween.set_ease(Tween.EASE_IN).tween_property(self, "scale", Vector2.ONE, 0.1)
	
func shrink_out() -> void:
	clickable = false
	if tween: tween.kill()
	tween = create_tween().set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN).tween_property(self, "scale", Vector2.ZERO, 0.2)
	tween.tween_callback(queue_free)

func _gui_input(event: InputEvent) -> void:
	if not clickable: return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		clicked.emit()

func _ready() -> void:
	set_clickable(clickable)

func _on_mouse_entered() -> void:
	if clickable:
		$Hover.play()
		scale = Vector2.ONE * 1.05

func _on_mouse_exited() -> void:
	if clickable: scale = Vector2.ONE
