extends MicroGame
class_name FindASeat

func _ready() -> void:
	initialize_seats()
	
func initialize_seats() -> void:
	for seat: Sprite2D in $Seats.get_children():
		var table = Sprite2D.new()
		table.texture = preload("res://micro_games/find_a_seat/assets/seat_table.png")
		table.z_index = 1
		seat.add_child(table)
