extends Node2D

const ICEBLOCK_PATH = "res://engine/objects/items/ice_block/ice_block.tscn"

func _ready() -> void:
	(func():
		var ice := NodeCreator.prepare_2d(load(ICEBLOCK_PATH), self) \
			.create_2d(true) \
			.get_node() as PhysicsBody2D
		ice.z_index = -999
	).call_deferred()
