extends Transition
class_name DebugTransition

@export var text : String
@export var time : float

func execute(context : TransitionContext, event : GameEvent):
	print_debug(text)
	await context.root.get_tree().create_timer(time).timeout
