extends Control
class_name Game

@export_group("Timers")

@export var default_timer_no_UI : PackedScene
@export var default_timer_with_UI : PackedScene

@onready var default_timers = [
	default_timer_no_UI, 
	default_timer_with_UI
]

@export_group("Micro Games")
@export var release_pack : MicroGamePack
@export var test_pack : MicroGamePack

enum GamePackSelection {
	ReleaseGames,
	TestOnly
}

@export var game_pack_selection : GamePackSelection
@export var game_selector : GameSelector

@onready var all_games : Array[MicroGameInfo] 
@onready var music_player : AudioStreamPlayer = $AudioStreamPlayer

func load_all_game_info():
	if game_pack_selection == GamePackSelection.ReleaseGames:
		all_games = release_pack.micro_games.duplicate() 

	elif game_pack_selection == GamePackSelection.TestOnly:
		all_games = test_pack.micro_games.duplicate()

func _ready() -> void:
	load_all_game_info()
	GameManager.enter_screen.connect(on_screen_enter)
	GameManager.exit_screen.connect(on_screen_exit)
	GameManager.refresh_ui.connect(on_rebuild)


func _reset_cursor() -> void:
	for i in range(0, 17):
		Input.set_custom_mouse_cursor(null, i)
		
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)


var current_game : MicroGame
var default_timer : MicroGameTimer

var lives = 3
var score = 0

func on_rebuild(screen):
	if screen != GameManager.Screen.Game:
		return
		
	game_selector.reload(all_games)

func on_screen_enter(screen):
	if screen != GameManager.Screen.Game:
		return
		
	music_player.play()
	_reset_cursor()
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

	lives = 3
	score = 0

	current_game = null
	default_timer = null
	play_next_game()
	
func on_screen_exit(screen):
	if screen != GameManager.Screen.Game:
		return
	music_player.stop()
	_reset_cursor()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


@onready var game_viewport = %GameViewport
@onready var in_game_ui = "."

func setup_micro_game(micro_game : MicroGame, info : MicroGameInfo):
	if micro_game.timer == null:
		default_timer = null
		
		if micro_game.timer_type != MicroGame.DefaultTimerType.CustomTimer:
			default_timer = default_timers[micro_game.timer_type].instantiate()
			add_child(default_timer)

		elif micro_game.timer == null:
			push_warning("a micro_game with a custom timer did not provide it!")
			default_timer = default_timer_no_UI.instantiate()
			add_child(default_timer)

		micro_game.timer = default_timer
	
	
	if info.width > 0 and info.height > 0:
		game_viewport.size_2d_override.x = info.width
		game_viewport.size_2d_override.y = info.height
	
	else:
		game_viewport.size_2d_override.x = 0
		game_viewport.size_2d_override.y = 0
	
	game_viewport.add_child(micro_game)
	
	
	current_game = micro_game

func start_game():
	print("playing game: ", game_selector.current_game.title, " lives: ", lives, " score: ", score)
	current_game.timer.timeout.connect(on_game_timeout)
	current_game.win.connect(on_game_end.bind(true))
	current_game.lose.connect(on_game_end.bind(false))

	current_game.start.emit()
	current_game.timer.start(current_game.game_duration)

func on_game_timeout():
	if current_game.lose_on_timeout:
		current_game.lose.emit()
	else:
		current_game.win.emit()

func on_game_end(win: bool):
	current_game.timer.stop()
	await get_tree().create_timer(current_game.post_game_time).timeout

	if win:
		score += 1
	else:
		lives -= 1

	if current_game:
		unload_game()

	play_next_game()

func unload_game():
	if default_timer:
		default_timer.queue_free()
	
	if current_game:
		current_game.get_parent().remove_child(current_game)
	game_selector.end_current_game()
	
	game_viewport.size_2d_override.x = 0
	game_viewport.size_2d_override.y = 0

func play_next_game():
	if lives == 0:
		GameManager.go_to_end()
		return
	
	var micro_game : MicroGame = game_selector.get_next_game()
	
	if micro_game == null:
		push_warning("failed to load another game!")
		GameManager.go_to_end()

	else:
		setup_micro_game(micro_game, game_selector.current_game)
		start_game()
