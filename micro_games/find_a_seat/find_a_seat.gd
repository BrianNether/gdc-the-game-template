extends MicroGame
class_name FindASeat

static var hook_installed := false
static var free_seats: int = 3

func _ready() -> void:
	FindASeatStudent.reset_appearance_pool()
	initialize_seats()
	initialize_students()
	if not hook_installed:
		hook_installed = true
		GameManager.exit_screen.connect(_on_screen_exited)
	
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
		occupied_seats.pop_front()
	for seat: Sprite2D in occupied_seats:
		var student: FindASeatStudent = preload("res://micro_games/find_a_seat/student.tscn").instantiate()
		seat.add_child(student)
	if free_seats > 1: free_seats -= 1
		
static func _on_screen_exited(screen: GameManager.Screen) -> void:
	if screen == GameManager.Screen.Game:
		free_seats = 3
