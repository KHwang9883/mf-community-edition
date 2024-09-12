extends Node

func _ready() -> void:
	await get_tree().create_timer(1.0, false).timeout
	print(Thunder._current_player._suit_resource_path)
	print(Thunder._current_player.suit)
