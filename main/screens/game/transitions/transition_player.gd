extends Resource
class_name TransitionSelector

@export var enter_micro_game : Transition
@export var exit_micro_game : Transition
@export var lose_micro_game : Transition
@export var win_micro_game : Transition

@export var increase_score : Transition
@export var decrease_lives : Transition


func play_increase_score(context : TransitionContext, event : GameEvent):
	pass

func decrease_lives_score(context : TransitionContext, event : GameEvent):
	pass

func micro_game_event(context : TransitionContext, event : GameEvent):
	pass
