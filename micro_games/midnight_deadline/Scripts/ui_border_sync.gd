@tool
extends Control
## Attach alongside a ShaderMaterial (e.g. uiborder.gdshader) to keep its
## `rect_size` uniform matched to the node's actual size, live in the
## editor too. Duplicates the material once so multiple nodes can share the
## same resource without fighting over one rect_size value.

## Toggle to force a sync without reloading the scene.
@export var force_resync: bool = false:
	set(_value):
		_ensure_synced()

var _material_duplicated := false


func _ready() -> void:
	_ensure_synced()
	resized.connect(_sync)


func _ensure_synced() -> void:
	if not (material is ShaderMaterial):
		push_warning(
			"ui_border_sync.gd on '%s' has no ShaderMaterial in its `material` property "
			% name +
			"(found: %s) - this node's material and this script must be on the SAME node. "
			% [material] +
			"rect_size will NOT be synced."
		)
		return
	if not _material_duplicated:
		material = material.duplicate()
		_material_duplicated = true
	_sync()


func _sync() -> void:
	material.set_shader_parameter("rect_size", size)
