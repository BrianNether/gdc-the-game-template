extends Control

@onready var medal_texture_rect := $HBoxContainer/Left/HBoxContainer/MedalTextureRect
@onready var rank_label := $HBoxContainer/Left/HBoxContainer/RankLabel
@onready var name_label := $HBoxContainer/Left/HBoxContainer/NameLabel
@onready var score_label := $HBoxContainer/Right/ScoreLabel
@onready var colour_rect := $ColorRect

var score_res : ScoreResource:
	set(new):
		score_res = new
		if new == null:
			return
		name_label.text = score_res.player_name
		score_label.text = str(score_res.score)

var rank : int:
	set(new):
		rank = new
		rank_label.text = str(rank) + "."
		match rank:
			1:
				pass
			2:
				pass
			3:
				pass

var colour : Color:
	set(new):
		colour = new
		colour_rect.color = colour
