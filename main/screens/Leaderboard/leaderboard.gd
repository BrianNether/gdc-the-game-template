extends ScreenRoot

@onready var local_leaderboard := $MarginContainer/VBoxContainer/HBoxContainer/LocalLeaderboardList
@onready var today_leaderboard := $MarginContainer/VBoxContainer/HBoxContainer/TodayLeaderboardList
@onready var alltime_leaderboard := $MarginContainer/VBoxContainer/HBoxContainer/AllTimeLeaderboardList

func update_today(scores:Array[ScoreResource]):
	today_leaderboard.display_score_list(scores)

func update_alltime(scores:Array[ScoreResource]):
	alltime_leaderboard.display_score_list(scores)

func _on_visibility_changed():
	if visible:
		pass
		# update leaderboards
