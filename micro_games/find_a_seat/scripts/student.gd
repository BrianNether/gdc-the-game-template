extends Node2D
class_name FindASeatStudent

const PATH_NORMIE_HEADS = "res://micro_games/find_a_seat/assets/heads_normie"
const PATH_NORMIE_BODIES = "res://micro_games/find_a_seat/assets/bodies_normie"
const PATH_SPECIAL_HEADS = "res://micro_games/find_a_seat/assets/heads_special"
const PATH_SPECIAL_BODIES = "res://micro_games/find_a_seat/assets/bodies_special"

const FRAME_COUNT = 3

const MAX_SPECIAL_COUNT = 5
static var special_count = MAX_SPECIAL_COUNT
static var used_special_heads: Array[String]

static func reset_appearance_pool() -> void:
	special_count = MAX_SPECIAL_COUNT
	used_special_heads.clear()
	
static func get_png_files(path: String) -> Array:
	var files := DirAccess.get_files_at(path)
	for file in files.duplicate():
		if not file.ends_with(".png"):
			files.erase(file)
	return Array(files)

func choose_appearance_normie() -> void:
	var head_file: String = get_png_files(PATH_NORMIE_HEADS).pick_random()
	var body_file: String = get_png_files(PATH_NORMIE_HEADS).pick_random()
	var head_sheet: Texture2D = load(PATH_NORMIE_HEADS + "/" + head_file)
	var body_sheet: Texture2D = load(PATH_NORMIE_BODIES + "/" + body_file)
	set_sprites_from_sheets(head_sheet, body_sheet)
	
func choose_appearance_special() -> void:
	var head_files := get_png_files(PATH_SPECIAL_HEADS)
	if len(used_special_heads) >= len(head_files): used_special_heads.clear()
	for file in used_special_heads: head_files.erase(file)
	var head_file: String = head_files.pick_random()
	used_special_heads.append(head_file)
	var body_files := get_png_files(PATH_SPECIAL_BODIES)
	var head_sheet: Texture2D = load(PATH_SPECIAL_HEADS + "/" + head_file)
	if head_file in body_files:
		var body_sheet: Texture2D = load(PATH_SPECIAL_BODIES + "/" + head_file)
		set_sprites_from_sheets(head_sheet, body_sheet)
	else:
		set_sprites_from_sheets(head_sheet, null)

func choose_appearance() -> void:
	if special_count > 0:
		special_count -= 1
		choose_appearance_special()
	else:
		choose_appearance_normie()
		
func set_sprites_from_sheets(head_sheet: Texture2D, body_sheet: Texture2D) -> void:
	set_sprite_from_sheet($Head, head_sheet)
	set_sprite_from_sheet($Body, body_sheet)
	
func set_sprite_from_sheet(sprite: AnimatedSprite2D, sheet: Texture2D) -> void:
	if sheet == null:
		sprite.visible = false
		return
	sprite.visible = true
	var frames := sprite.sprite_frames
	var frame_size := sheet.get_size() * Vector2(1.0 / FRAME_COUNT, 1.0)
	frames.clear("default")
	for frame_index in range(FRAME_COUNT):
		var frame := AtlasTexture.new()
		frame.atlas = sheet
		frame.region = Rect2(frame_size * Vector2.RIGHT * frame_index, frame_size)
		frames.add_frame("default", frame)

func _ready() -> void:
	choose_appearance()
