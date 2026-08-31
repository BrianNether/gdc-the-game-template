extends Resource
class_name ScoreResource

var player_name : String
var score : int

func _init(player_name : String, score : int):
	self.player_name = player_name
	self.score = score
