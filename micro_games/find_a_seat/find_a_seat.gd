extends MicroGame
class_name FindASeat

static var hook_installed := false
static var free_seats: int = 3

var won = false

# TODO
# 7-segment timer
# Dev-chan collapses in despair when failing
# Sound effects
# Easter egg characters

func _ready() -> void:
	FindASeatStudent.reset_appearance_pool()
	$Timer.frame = 10 - game_duration
	start.connect(_on_start)
	initialize_seats()
	initialize_students()
	if not hook_installed:
		hook_installed = true
		GameManager.exit_screen.connect(_on_screen_exited)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
func _on_start() -> void:
	$Timer.play()
	
func initialize_seats() -> void:
	for seat: Sprite2D in $Seats.get_children():
		var table = Sprite2D.new()
		table.texture = preload("res://micro_games/find_a_seat/assets/seat_table.png")
		table.z_index = 1
		seat.add_child(table)

func initialize_students() -> void:
	var occupied_seats := $Seats.get_children()
	occupied_seats.shuffle()
	for i in range(free_seats):
		var seat: Sprite2D = occupied_seats.pop_front()
		var empty_seat: FindASeatEmptySeat = preload("res://micro_games/find_a_seat/empty_seat.tscn").instantiate()
		seat.add_child(empty_seat)
		empty_seat.clicked.connect(seat_found.bind(empty_seat))
	for seat: Sprite2D in occupied_seats:
		var student: FindASeatStudent = preload("res://micro_games/find_a_seat/student.tscn").instantiate()
		seat.add_child(student)
	if free_seats > 1: free_seats -= 1
	
func dev_chan_hop_to(end_point: Vector2) -> void:
	const HOP_DISTANCE = 32
	var start_point: Vector2 = $DevChan.global_position
	var hops: int = floor(start_point.distance_to(end_point) / HOP_DISTANCE)
	var hop_distance: float = start_point.distance_to(end_point) / hops
	for i in range(hops):
		var move_tween := create_tween()
		var hop_tween := create_tween().set_trans(Tween.TRANS_QUAD)
		move_tween.tween_property($DevChan, "global_position", start_point + start_point.direction_to(end_point) * hop_distance * (i + 1), 0.2)
		hop_tween.set_ease(Tween.EASE_OUT).tween_property($DevChan/Body, "position", Vector2.UP * 16, 0.1)
		hop_tween.set_ease(Tween.EASE_IN).tween_property($DevChan/Body, "position", Vector2.ZERO, 0.1)
		await move_tween.finished
	
func seat_found(seat: FindASeatEmptySeat) -> void:
	if won: return
	won = true
	$DevChan/Body/Head.play("default")
	$DevChan/Body/Head/Sweat.visible = false
	var midpoint := Vector2($DevChan.global_position.x, seat.global_position.y)
	await dev_chan_hop_to(midpoint)
	await dev_chan_hop_to(seat.global_position)
	#tween.tween_property($DevChan, "global_position", midpoint, $DevChan.global_position.distance_to(midpoint) / SPEED)
	#tween.tween_property($DevChan, "global_position", seat.global_position, midpoint.distance_to(seat.global_position) / SPEED)
		
static func _on_screen_exited(screen: GameManager.Screen) -> void:
	if screen == GameManager.Screen.Game:
		free_seats = 3
