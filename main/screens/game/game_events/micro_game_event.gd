extends GameEvent
class_name MicroGameEvent

enum StateChange {
	ENTER,
	EXIT,
} 

enum Outcome {
	NONE,
	WIN,
	LOSE
}

enum OutcomeReason {
	NONE,
	PLAYER_ACTION,
	TIMEOUT
}

var info: MicroGameInfo

var state_change : StateChange
var outcome : Outcome
var outcome_reason : OutcomeReason

func _init(info : MicroGameInfo, state_change : StateChange, outcome : Outcome, outcome_reason : OutcomeReason):
	super()
	self.info = info
	self.state_change = state_change
	self.outcome = outcome
	self.outcome_reason = outcome_reason
