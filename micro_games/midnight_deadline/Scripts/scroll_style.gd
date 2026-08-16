@tool
extends ScrollContainer
## Swaps a custom script onto the internally-created v-scrollbar at runtime,
## via get_v_scroll_bar() + set_script(). set_script() doesn't trigger
## _ready(), so setup() is called explicitly.

## Toggle to force the swap without reloading the scene.
@export var force_resync: bool = false:
	set(_value):
		_apply()


func _ready() -> void:
	_apply()


func _apply() -> void:
	var vbar := get_v_scroll_bar()
	if vbar == null:
		return
	if not (vbar.get_script() is GDScript) or (vbar.get_script() as GDScript).resource_path != "res://micro_games/midnight_deadline/Scripts/pixel_scrollbar.gd":
		vbar.set_script(load("res://micro_games/midnight_deadline/Scripts/pixel_scrollbar.gd"))
	vbar.setup()
