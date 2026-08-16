@tool
extends GridContainer
## Populates itself with one correct file plus filler files (PDFs, C++
## files, folders, one Riot Client), shuffled every load. Every entry is
## draggable - submitting a wrong one loses too. Expects to be inside a
## ScrollContainer.
##
## Children are deliberately NOT given an owner, or Godot would bake
## whatever shuffle was showing into the .tscn on save.

const FileEntryScenePath := "res://micro_games/midnight_deadline/file_entry.tscn"

@export_group("Icons")
@export var pdf_icon: Texture2D
@export var cpp_icon: Texture2D
@export var folder_icon: Texture2D
@export var riot_icon: Texture2D

@export_group("Real File")
@export var real_file_name := "Final_Essay.pdf"
@export var real_file_payload_type := "submit_file"

@export_group("Filler Files")
@export var pdf_filler_names: PackedStringArray = [
	"Notes.pdf",
	"Old_Draft.pdf",
	"Syllabus.pdf",
]
@export var cpp_filler_names: PackedStringArray = [
	"main.cpp",
	"game.cpp",
	"utils.cpp",
]
@export var folder_filler_names: PackedStringArray = [
	"Homework",
	"Photos",
	"Downloads",
]
## Single name, not a pool - so there's never more than one Riot Client.
@export var riot_client_name := "Riot Client"

## _ready() doesn't refire on script/prop changes to an already-open node -
## toggle to force a re-populate without reloading the scene.
@export_group("")
@export var force_resync: bool = false:
	set(_value):
		_populate()


func _ready() -> void:
	_populate()


func _populate() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()

	# force a fresh read instead of preload()'s cached reference
	var file_entry_scene := ResourceLoader.load(
		FileEntryScenePath, "", ResourceLoader.CACHE_MODE_REPLACE
	) as PackedScene

	var specs: Array[Dictionary] = []
	specs.append({"name": real_file_name, "icon": pdf_icon, "correct": true})
	for n in pdf_filler_names:
		specs.append({"name": n, "icon": pdf_icon, "correct": false})
	for n in cpp_filler_names:
		specs.append({"name": n, "icon": cpp_icon, "correct": false})
	for n in folder_filler_names:
		specs.append({"name": n, "icon": folder_icon, "correct": false})
	specs.append({"name": riot_client_name, "icon": riot_icon, "correct": false})
	specs.shuffle()

	for spec in specs:
		var entry: FileEntry = file_entry_scene.instantiate()
		add_child(entry)
		entry.icon_texture = spec["icon"]
		entry.caption_text = spec["name"]
		entry.draggable = true
		entry.is_correct_file = spec["correct"]
		entry.drag_payload_type = real_file_payload_type

	queue_sort()
	# needs a nudge next idle frame too, or the editor sometimes misses it
	queue_sort.call_deferred()
