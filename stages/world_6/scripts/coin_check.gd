extends Node2D

@onready var coins = get_children()

func check_for_treasure() -> void:
	var no_treasure: bool = false
	for i in get_children():
		if is_instance_valid(i) && i in coins:
			no_treasure = true
			break
	if no_treasure: return
	
	Data.values.treasure = true
