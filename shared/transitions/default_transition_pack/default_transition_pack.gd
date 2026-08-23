extends Transition

const Animations = preload("res://shared/transitions/default_transition_pack/animations.gd") 

@export var overlay : PackedScene = preload("res://shared/transitions/default_transition_pack/animations.tscn")

func execute(context : TransitionContext, event : GameEvent):
	if event is IncreaseScoreEvent:
		context.background_layer.visible = true
		context.game_layer.visible = false
		context.overlay_layer.visible = true
		var t = overlay.instantiate() as Animations
		context.overlay_layer.add_child(t)
		
		await t.update_score(event.new_score, event.previous_score)
		
		context.overlay_layer.remove_child(t)
		t.queue_free()
		
		context.game_layer.visible = true
		context.overlay_layer.visible = false
	
	elif event is DecreaseLivesEvent:
		context.background_layer.visible = true
		context.game_layer.visible = false
		context.overlay_layer.visible = true
		var t = overlay.instantiate() as Animations
		context.overlay_layer.add_child(t)
		
		await t.update_lives(event.new_lives, event.previous_lives)
		
		context.overlay_layer.remove_child(t)
		t.queue_free()
		context.game_layer.visible = true
		context.overlay_layer.visible = false
		
	elif event is MicroGameEvent and event.state_change == MicroGameEvent.StateChange.ENTER:
		context.background_layer.visible = true
		context.game_layer.visible = false
		context.overlay_layer.visible = true
		var t = overlay.instantiate() as Animations
		context.overlay_layer.add_child(t)
		
		await t.display_controls(event.info)
		
		context.overlay_layer.remove_child(t)
		t.queue_free()
		context.game_layer.visible = true
		context.overlay_layer.visible = false
		
		
