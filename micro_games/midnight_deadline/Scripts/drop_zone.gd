extends Control

const GameSFX = preload("res://micro_games/midnight_deadline/Scripts/game_sfx.gd")

## Accepts a drag from a file_entry.gd Control. Expects two children:
## "IdleState" (default look, "Label" child shows dropped file name once the
## upload flash finishes) and "HoverState" (shown while dragging over).
##
## Any file can be dropped; a new drop overwrites the previous one until
## lock() is called. `file_received` fires after the upload flash finishes,
## not on the drop itself.

signal file_received

@export var accepted_payload_type := "submit_file"
## Label color once the upload flash finishes and shows the file name.
@export var done_text_color: Color = Color(0.20392157, 0.49411765, 0.8235294, 1.0)

@export_group("Upload Flash")
@export var upload_flash_color: Color = Color(0.2, 0.9, 0.3, 0.35)
@export var upload_flash_duration: float = 0.8
## Match to the border width so the flash stays inside it.
@export var upload_flash_inset: float = 10.0

## Whether the currently held file is the correct one - Submit reads this.
var dropped_file_correct := false
var dropped_file_name := ""

var _locked := false
var _drag_hovering := false
var _flash_tween: Tween
var _flash_overlay: ColorRect

@onready var idle_state: Control = get_node_or_null("IdleState")
@onready var hover_state: Control = get_node_or_null("HoverState")
@onready var idle_label: Label = idle_state.get_node_or_null("Label") if idle_state else null


func _ready() -> void:
	clip_contents = true
	mouse_exited.connect(_on_mouse_exited)
	pivot_offset = size * 0.5
	resized.connect(func(): pivot_offset = size * 0.5)
	_update_visual_state()


## Blocks further drops once the round ends.
func lock() -> void:
	_locked = true
	_drag_hovering = false
	_update_visual_state()


func _can_drop_data(_at_position: Vector2, data) -> bool:
	var can: bool = not _locked and typeof(data) == TYPE_DICTIONARY and data.get("type") == accepted_payload_type
	if can != _drag_hovering:
		_drag_hovering = can
		_update_visual_state()
		if can:
			GameSFX.play(self, "res://micro_games/midnight_deadline/Assets/hover.wav", -8.0)
	return can


func _drop_data(_at_position: Vector2, data) -> void:
	if _locked:
		return
	dropped_file_correct = typeof(data) == TYPE_DICTIONARY and data.get("is_correct", false)
	dropped_file_name = str(data.get("name", "")) if typeof(data) == TYPE_DICTIONARY else ""
	_drag_hovering = false
	_update_visual_state()
	_play_upload_flash()
	_play_drop_reaction()


## Pop bounce plus a shake on a wrong file. No correct/wrong sound here -
## that's reserved for actually submitting.
func _play_drop_reaction() -> void:
	scale = Vector2(1.06, 1.06)
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if not dropped_file_correct:
		_shake()


func _shake() -> void:
	var base_pos: Vector2 = position
	var shake_tween := create_tween()
	for i in range(3):
		shake_tween.tween_property(self, "position", base_pos + Vector2(randf_range(-3.0, 3.0), 0.0), 0.025)
	shake_tween.tween_property(self, "position", base_pos, 0.025)


func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END and _drag_hovering:
		_drag_hovering = false
		_update_visual_state()


func _on_mouse_exited() -> void:
	if _drag_hovering:
		_drag_hovering = false
		_update_visual_state()


func _update_visual_state() -> void:
	var show_hover := _drag_hovering
	if idle_state:
		idle_state.visible = not show_hover
	if hover_state:
		hover_state.visible = show_hover


func _play_upload_flash() -> void:
	# an overwrite mid-flash replaces it outright rather than stacking
	if _flash_tween and _flash_tween.is_valid():
		_flash_tween.kill()
	if _flash_overlay and is_instance_valid(_flash_overlay):
		_flash_overlay.queue_free()

	var inset := upload_flash_inset
	var overlay := ColorRect.new()
	overlay.color = upload_flash_color
	overlay.position = Vector2(inset, inset)
	overlay.size = Vector2(0, maxf(size.y - inset * 2.0, 0.0))
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(overlay)
	_flash_overlay = overlay
	GameSFX.play(self, "res://micro_games/midnight_deadline/Assets/softclick.wav", -10.0)

	var target_width: float = maxf(size.x - inset * 2.0, 0.0)
	var tween := create_tween()
	_flash_tween = tween
	tween.tween_property(overlay, "size:x", target_width, upload_flash_duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_callback(_on_upload_flash_finished.bind(overlay))


func _on_upload_flash_finished(overlay: ColorRect) -> void:
	if is_instance_valid(overlay):
		overlay.queue_free()
	if idle_label:
		idle_label.text = dropped_file_name
		idle_label.add_theme_color_override("font_color", done_text_color)
	GameSFX.play(self, "res://micro_games/midnight_deadline/Assets/submit.mp3", -4.0)
	file_received.emit()
