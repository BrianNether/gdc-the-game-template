extends Resource
class_name GameSelector

@export var do_randomize : bool = true
@export var play_all_before_repeat : bool = true
@export var look_ahead_distance : int = 5
@export var look_back_distance : int = 5


var all_games : Array[MicroGameInfo]

var cached_games : Dictionary[MicroGameInfo, MicroGame]
var micro_game_pool : Array[MicroGameInfo]

var last_games : Array[MicroGameInfo] 

var current_game : MicroGameInfo


func load_game(info: MicroGameInfo) -> MicroGame:
	if cached_games.has(info):
		return cached_games.get(info)
	
	if info.game_scene == null or not info.game_scene.can_instantiate():
		return null
	
	var game = info.game_scene.instantiate()
	
	if game is MicroGame:
		
		# dont cache anything for now
		if false and (not game.always_reload):
			cached_games.set(info, game)
		
		return game

	else:
		game.queue_free()
		cached_games.set(info, null)
		return null

func end_current_game():
	if current_game != null:
		last_games.push_front(current_game)
		current_game = null

func get_next_game() -> MicroGame:
	current_game = all_games.pick_random()
	return load_game(current_game)

func reset():
	micro_game_pool = all_games.duplicate()
	current_game = null
	last_games.clear()

func reload(games: Array[MicroGameInfo]):
	all_games = games.duplicate()
	micro_game_pool = games.duplicate()
	
	for game in cached_games.values():
		game.queue_free()
		
	cached_games.clear()
