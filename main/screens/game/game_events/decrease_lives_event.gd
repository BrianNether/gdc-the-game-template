extends GameEvent
class_name DecreaseLivesEvent

var previous_lives: int
var new_lives: int

func _init(new_lives: int, previous_lives: int):
	super()
	self.previous_lives = previous_lives
	self.new_lives = new_lives
