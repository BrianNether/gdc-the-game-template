class_name ScoreCreator
extends Control

const TALO_alltime_leaderboard_name : String = "All Time Leaderboard"
const TALO_daily_leaderboard_name : String = "Daily Leaderboard"

# To be used to save scores locally
signal score_created(score_resource:ScoreResource)

@onready var enter_leaderboard_button := $VBoxContainer/CenterContainer/EnterLeaderboardButton
@onready var name_input := $VBoxContainer/Control/CenterContainer/NameInput
@onready var score_label := $VBoxContainer/ScoreDisplay/ScoreLabel
@onready var uploading_state_notification := $UploadingStateNotification
@onready var con_test := $ConnectionTest

var score : int:
	set(new):
		score = new
		score_label.text = str(score)

func open_creator(s:int):
	name_input.show()
	show()
	name_input.text = ""
	score = s


func enter_score():
	uploading_state_notification.show()
	enter_leaderboard_button.disabled = true
	name_input.hide()
	var new_score := ScoreResource.new(name_input.text, score)
	score_created.emit(new_score)
	con_test.test_connection()
	await con_test.request_completed
	if con_test.most_recent_result:
		await Talo.players.identify("username", name_input.text)
		var res_alltime := await Talo.leaderboards.add_entry(TALO_alltime_leaderboard_name, new_score.score)
		var res_daily := await Talo.leaderboards.add_entry(TALO_daily_leaderboard_name, new_score.score)
		uploading_state_notification.hide()
	hide()


func _on_name_input_name_created():
	enter_leaderboard_button.disabled = false


func _on_name_input_name_deleted():
	enter_leaderboard_button.disabled = true


func _on_skip_button_pressed():
	hide()
