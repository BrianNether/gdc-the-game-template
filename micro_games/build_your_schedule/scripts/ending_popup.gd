extends Panel
class_name BuildSchedulePopup

@onready var background: ColorRect = $"../PopupBackground"

func _ready() -> void:
	scale = Vector2.ZERO

func appear(win: bool) -> void:
	if win:
		$Win.play()
		$Header.text = "SUCCESS!"
		$Text.text = "Thank you for taking the time to choose your courses with thought and care."
	else:
		$Lose.play()
		var insult: String = ["bozo", "dingus", "bud", "buddy", "loser", "slowpoke"].pick_random()
		$Header.text = "ERROR"
		$Text.text = "This page is no longer available.\nBetter luck next semester, %s." % insult
	background.visible = true
	var tween := create_tween().set_trans(Tween.TRANS_QUAD)
	tween.tween_property(background, "modulate", Color.WHITE, 0.2)
	tween.set_parallel().set_ease(Tween.EASE_OUT).tween_property(self, "scale", Vector2.ONE * 1.2, 0.2)
	tween.set_ease(Tween.EASE_IN).tween_property(self, "scale", Vector2.ONE, 0.1)
