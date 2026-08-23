extends Transition
class_name TransitionSequence

@export var transitions : Array[Transition]

func execute(context : TransitionContext, event : GameEvent):
	for t in transitions:
		await t.execute(context, event)
