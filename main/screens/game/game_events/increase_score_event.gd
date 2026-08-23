extends GameEvent
class_name IncreaseScoreEvent

var previous_score: int
var new_score: int

func _init(new_score: int, previous_score: int):
	super()
	self.previous_score = previous_score
	self.new_score = new_score
