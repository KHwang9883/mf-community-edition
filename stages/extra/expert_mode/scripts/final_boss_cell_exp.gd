extends "res://objects/final_boss_cell/final_boss_cell.gd"

func _ready() -> void:
	await get_tree().create_timer(2, false).timeout
	
	_creation_mushroom()
