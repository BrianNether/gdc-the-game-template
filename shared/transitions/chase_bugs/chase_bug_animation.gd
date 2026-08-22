extends Control

func play(enter : bool):
	$AnimatedSprite2D.frame = 0
	$AnimatedSprite2D.play("default")
	$AnimationPlayer.play("enter" if enter else "exit")
