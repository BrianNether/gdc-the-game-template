extends ScreenRoot

@onready var local_leaderboard := $MarginContainer/VBoxContainer/HBoxContainer/LocalLeaderboardList
@onready var today_leaderboard := $MarginContainer/VBoxContainer/HBoxContainer/TodayLeaderboardList
@onready var alltime_leaderboard := $MarginContainer/VBoxContainer/HBoxContainer/AllTimeLeaderboardList
@onready var http_request := $HTTPRequest

@export var local_data_manager : LocalDataManager

const TALO_alltime_leaderboard_name : String = "All Time Leaderboard"
const TALO_daily_leaderboard_name : String = "Daily Leaderboard"

func update_local(scores:Array[ScoreResource]):
	local_leaderboard.display_score_list(scores)

func update_today(scores:Array[ScoreResource]):
	today_leaderboard.display_score_list(scores)

func update_alltime(scores:Array[ScoreResource]):
	alltime_leaderboard.display_score_list(scores)

func _on_visibility_changed():
	if visible:
		_build_local_entries()
		http_request.test_connection()
		await http_request.request_completed
		if true:#http_request.most_recent_result:
			_get_online_leaderboards()
		
		

func _get_online_leaderboards():
	var page := 0
	var done := false
	while !done:
		var options := Talo.leaderboards.GetEntriesOptions.new()
		options.page = page
		var alltime_res := await Talo.leaderboards.get_entries(TALO_alltime_leaderboard_name, options)
		done = true
		#var is_last_page : bool = alltime_res.is_last_page
		#if is_last_page:
		#	done = true
	
	page = 0
	done = false
	while !done:
		var options := Talo.leaderboards.GetEntriesOptions.new()
		options.page = page
		var daily_res := await Talo.leaderboards.get_entries(TALO_daily_leaderboard_name, options)
		done = true
		#var is_last_page : bool = daily_res.is_last_page
		#if is_last_page:
		#	done = true
	
	_build_online_entries()

func _build_online_entries():
	var daily_list : Array[ScoreResource]
	var alltime_list : Array[ScoreResource]
	if http_request.most_recent_result:
		for entry in Talo.leaderboards.get_cached_entries(TALO_alltime_leaderboard_name):
			alltime_list.append(_entry_to_score_res(entry))
		for entry in Talo.leaderboards.get_cached_entries(TALO_daily_leaderboard_name):
			daily_list.append(_entry_to_score_res(entry))
	update_alltime(alltime_list)
	update_today(daily_list)

func _build_local_entries():
	if local_data_manager != null:
		update_local(local_data_manager.get_scores())

func _entry_to_score_res(entry:TaloLeaderboardEntry) -> ScoreResource:
	var player_name : String = entry.player_alias.identifier
	var player_score : int = entry.score
	return ScoreResource.new(player_name, player_score)
