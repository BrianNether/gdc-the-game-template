extends RefCounted
## Thin wrapper around a one-shot AudioStreamPlayer for the game's real sound
## assets (Assets/*.wav, *.mp3) - creates a throwaway player, plays it, and
## frees itself once done.

static func play(parent: Node, path: String, volume_db: float = 0.0) -> void:
	if Engine.is_editor_hint():
		return
	var player := AudioStreamPlayer.new()
	player.stream = load(path)
	player.volume_db = volume_db
	parent.add_child(player)
	player.play()
	player.finished.connect(player.queue_free)
