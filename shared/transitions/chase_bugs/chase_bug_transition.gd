extends Transition


@export var overlay : PackedScene = preload("res://shared/transitions/chase_bugs/chase_bug_animation.tscn")

func execute(context : TransitionContext, event : GameEvent):
	context.background_layer.visible = false
	context.game_layer.visible = true
	context.overlay_layer.visible = true
	
	var t = overlay.instantiate() 
	context.overlay_layer.add_child(t)
	
	t.play((event as MicroGameEvent).state_change == MicroGameEvent.StateChange.ENTER)

	await context.root.get_tree().create_timer(18.0/12.0).timeout
	
	context.overlay_layer.remove_child(t)
	t.queue_free()
	context.overlay_layer.visible = false
	context.game_layer.visible = true
	context.background_layer.visible = true
	
