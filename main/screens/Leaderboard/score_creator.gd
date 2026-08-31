class_name ScoreCreator
extends Control

signal score_created(score : ScoreResource)

@onready var enter_leaderboard_button := $VBoxContainer/CenterContainer/EnterLeaderboardButton
@onready var name_input := $VBoxContainer/Control/CenterContainer/NameInput
@onready var score_label := $VBoxContainer/ScoreDisplay/ScoreLabel

var score : int:
	set(new):
		score = new
		score_label.text = str(score)

func open_creator(s:int):
	show()
	name_input.text = ""
	score = s


func enter_score():
	score_created.emit(ScoreResource.new(name_input.text, score))
	
	hide()


func _on_name_input_name_created():
	enter_leaderboard_button.disabled = false


func _on_name_input_name_deleted():
	enter_leaderboard_button.disabled = true


func _on_skip_button_pressed():
	hide()
