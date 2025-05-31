class_name GameOptions
extends Object

var number_of_rounds : int = 3
var is_two_player : bool = false

func _init(num_rounds: int, two_player: bool) -> void:
	if num_rounds <= 0:
		push_error("num_rounds (%d) must be > 0" % num_rounds)
	number_of_rounds = num_rounds
	is_two_player = two_player
