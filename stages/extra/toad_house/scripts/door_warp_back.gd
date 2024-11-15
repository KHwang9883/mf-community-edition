extends Node

@onready var door_in: Area2D = $".."

func _ready() -> void:
	door_in.warp_to_scene = Data.technical_values.get(&"map_scene", "res://stages/save_game_room/save_game_room.tscn")
