extends VBoxContainer

@export var leaderboard_name : String = "TODAY"
@onready var title_label := $TitleLabel

func _ready():
	title_label.text = leaderboard_name
