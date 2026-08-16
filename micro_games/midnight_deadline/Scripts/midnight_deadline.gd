extends MicroGame

const GameSFX = preload("res://micro_games/midnight_deadline/Scripts/game_sfx.gd")

## Drag the essay into the browser's dropzone and hit Submit before the
## taskbar clock hits 12:00:00. Logic only - visuals live in the .tscn,
## referenced here via scene-unique names (%DropZone, %SubmitButton,
## %ClockLabel). Win/lose is decided by asking the dropzone whether the
## currently held file is the correct one.

@onready var dropzone = %DropZone
@onready var submit_button: BaseButton = %SubmitButton
@onready var clock_label: Label = %ClockLabel

var file_dropped := false
var game_ended := false
var countdown_active := false
var elapsed_time := 0.0
var seconds_ticked := 0

var _clock_default_color: Color


func _ready() -> void:
	set_process(false)
	_setup_cursors()
	_add_black_backdrop()
	# so the urgent-red pulse can restore it later instead of falling back to theme white
	_clock_default_color = clock_label.get_theme_color("font_color")

	dropzone.file_received.connect(_on_file_dropped)
	submit_button.disabled = true
	submit_button.pressed.connect(_on_submit_pressed)

	start.connect(_on_start)
	win.connect(_on_win)
	lose.connect(_on_lose)


## Godot's default viewport clear is grey, not black - this covers whatever
## the CRT shutoff reveals behind the shrinking picture.
func _add_black_backdrop() -> void:
	var backdrop := ColorRect.new()
	backdrop.name = "Backdrop"
	backdrop.color = Color.BLACK
	backdrop.size = get_viewport_rect().size
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	backdrop.z_index = -100
	add_child(backdrop)
	move_child(backdrop, 0)


func _on_start() -> void:
	elapsed_time = 0.0
	seconds_ticked = 0
	countdown_active = true
	set_process(true)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	clock_label.add_theme_color_override("font_color", _clock_default_color)
	_update_clock_label()
	_play_window_intro()


func _process(delta: float) -> void:
	if not countdown_active:
		return

	elapsed_time += delta
	var whole_seconds := int(floor(elapsed_time))
	if whole_seconds > seconds_ticked:
		seconds_ticked = whole_seconds
		_update_clock_label()
		if seconds_ticked >= int(game_duration):
			countdown_active = false


func _update_clock_label() -> void:
	var duration := int(game_duration)
	var urgent := false
	if seconds_ticked >= duration:
		clock_label.text = "12:00:00"
		urgent = true
	else:
		var seconds_before_midnight := duration - seconds_ticked
		clock_label.text = "11:59:%02d" % (60 - seconds_before_midnight)
		urgent = seconds_before_midnight <= 2
	_pulse_clock(urgent)


## Per-second pulse, sharper and red-tinted in the last couple seconds.
func _pulse_clock(urgent: bool) -> void:
	clock_label.pivot_offset = clock_label.size * 0.5
	clock_label.scale = Vector2(1.16, 1.16) if urgent else Vector2(1.06, 1.06)
	var tween := create_tween()
	tween.tween_property(clock_label, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if urgent:
		clock_label.add_theme_color_override("font_color", Color(0.45, 0.05, 0.05))
		GameSFX.play(self, "res://micro_games/midnight_deadline/Assets/clock.wav", 0.0)
	else:
		GameSFX.play(self, "res://micro_games/midnight_deadline/Assets/clock.wav", -8.0)


## Scale/fade pop-in for the two windows once the round starts.
func _play_window_intro() -> void:
	for path in ["UI/FileExplorerWindow", "UI/BrowserWindow"]:
		var window := get_node_or_null(path)
		if not window:
			continue
		window.pivot_offset = window.size * 0.5
		window.scale = Vector2(0.9, 0.9)
		window.modulate.a = 0.0
		var tween := create_tween()
		tween.set_parallel(true)
		tween.tween_property(window, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(window, "modulate:a", 1.0, 0.2)


func _on_file_dropped() -> void:
	file_dropped = true
	submit_button.disabled = false


func _on_submit_pressed() -> void:
	if game_ended or not file_dropped:
		return
	game_ended = true
	if dropzone.dropped_file_correct:
		win.emit()
	else:
		lose.emit()


func _on_win() -> void:
	_end_round()
	_show_end_feedback(true)


func _on_lose() -> void:
	_end_round()
	_show_end_feedback(false)


func _end_round() -> void:
	game_ended = true
	countdown_active = false
	set_process(false)
	dropzone.lock()
	_lock_interactions()


## Blocks further interaction once the round ends, and hides the OS cursor
## (it renders above any in-game overlay otherwise, incl. the CRT shutoff).
func _lock_interactions() -> void:
	submit_button.disabled = true
	var blocker := Control.new()
	blocker.name = "InputBlocker"
	blocker.mouse_filter = Control.MOUSE_FILTER_STOP
	blocker.size = get_viewport_rect().size
	blocker.z_index = 200
	add_child(blocker)
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN


func _show_end_feedback(is_win: bool) -> void:
	var target_color: Color = Color(0.1, 0.85, 0.25, 0.35) if is_win else Color(0.9, 0.1, 0.1, 0.35)
	var overlay := ColorRect.new()
	overlay.color = Color(target_color.r, target_color.g, target_color.b, 0.0)
	overlay.size = get_viewport_rect().size
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Parented to UI so it collapses with everything else during the shutoff.
	var ui := get_node_or_null("UI")
	if ui:
		ui.add_child(overlay)
		# Must draw before CRTFilter so the shader's screen capture picks it up.
		var crt_filter := ui.get_node_or_null("CRTFilter")
		if crt_filter:
			ui.move_child(overlay, crt_filter.get_index())
	else:
		add_child(overlay)
	var tween := create_tween()
	tween.tween_property(overlay, "color:a", target_color.a, 0.25).set_trans(Tween.TRANS_SINE)

	if is_win:
		GameSFX.play(self, "res://micro_games/midnight_deadline/Assets/CorrectAnswer.wav", -4.0)
	else:
		GameSFX.play(self, "res://micro_games/midnight_deadline/Assets/WrongAnswer.wav", -4.0)
		_shake_screen()

	# tv_off.wav gets a 0.5s head start on the visual collapse
	var sound_timer := get_tree().create_timer(0.5)
	sound_timer.timeout.connect(func(): GameSFX.play(self, "res://micro_games/midnight_deadline/Assets/tv_off.wav", -2.0))
	var shutoff_timer := get_tree().create_timer(1.0)
	shutoff_timer.timeout.connect(_play_crt_shutoff)


## Classic CRT power-off: collapses to a line, then a point.
func _play_crt_shutoff() -> void:
	var ui := get_node_or_null("UI")
	if not ui:
		return
	var viewport_size := get_viewport_rect().size
	ui.pivot_offset = viewport_size * 0.5
	var tween := create_tween()
	tween.tween_property(ui, "scale:y", 0.01, 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(ui, "scale:x", 0.001, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	# scale never hits exactly 0 - hide it or a hairline sliver stays visible
	tween.tween_callback(func(): ui.visible = false)


func _shake_screen() -> void:
	var ui := get_node_or_null("UI")
	if not ui:
		return
	var base_pos: Vector2 = ui.position
	var shake_tween := create_tween()
	for i in range(3):
		shake_tween.tween_property(ui, "position", base_pos + Vector2(randf_range(-3.0, 3.0), randf_range(-3.0, 3.0)), 0.025)
	shake_tween.tween_property(ui, "position", base_pos, 0.025)


# set_custom_mouse_cursor() is global engine state - it stays applied after
# this microgame ends since Main never resets it (move to an autoload if
# that's not wanted).
const CURSOR_SCALE := 3.0

## Offset into the scaled texture so the cursor's contact point lines up
## with the actual pointer position.
const CURSOR_HOTSPOT := Vector2(10, 10)

func _setup_cursors() -> void:
	var arrow_texture := _load_cursor_texture("res://micro_games/midnight_deadline/Assets/cursor.png")
	var pointer_texture := _load_cursor_texture("res://micro_games/midnight_deadline/Assets/pointer.png")
	var cross_texture := _load_cursor_texture("res://micro_games/midnight_deadline/Assets/cross.png")
	Input.set_custom_mouse_cursor(arrow_texture, Input.CURSOR_ARROW, CURSOR_HOTSPOT)
	Input.set_custom_mouse_cursor(pointer_texture, Input.CURSOR_POINTING_HAND, CURSOR_HOTSPOT)
	Input.set_custom_mouse_cursor(pointer_texture, Input.CURSOR_DRAG, CURSOR_HOTSPOT)
	# shown automatically by Godot over valid drop targets / invalid ones
	Input.set_custom_mouse_cursor(pointer_texture, Input.CURSOR_CAN_DROP, CURSOR_HOTSPOT)
	Input.set_custom_mouse_cursor(cross_texture, Input.CURSOR_FORBIDDEN, CURSOR_HOTSPOT)


## Resized with nearest-neighbor to stay crisp at CURSOR_SCALE.
func _load_cursor_texture(path: String) -> Texture2D:
	var img: Image = load(path).get_image()
	img.resize(
		int(img.get_width() * CURSOR_SCALE),
		int(img.get_height() * CURSOR_SCALE),
		Image.INTERPOLATE_NEAREST
	)
	return ImageTexture.create_from_image(img)
