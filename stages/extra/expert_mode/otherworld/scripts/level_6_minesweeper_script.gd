extends Node2D

@onready var scr_tilemap: TileMapLayer = $"../Control2/TileMapLayer"

func _ready() -> void:
	hide()

func activate() -> void:
	show()
	process_mode = Node.PROCESS_MODE_INHERIT

func wait_for_it() -> void:
	var local_pos = scr_tilemap.local_to_map(scr_tilemap.to_local(get_child(0).global_position))
	scr_tilemap.set_cell(local_pos)
