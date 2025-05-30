extends "res://engine/objects/items/ice_block/ice_block_static.gd"

@onready var _path_follow = $".."

func _physics_process(delta: float) -> void:
	global_position = _path_follow.global_position
