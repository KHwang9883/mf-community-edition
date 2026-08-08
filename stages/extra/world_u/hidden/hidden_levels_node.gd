extends Node

func _ready() -> void:
	if ProfileManager.current_profile.data.get("warp_to_save_room"):
		var lvl: Level = Scenes.current_scene
		lvl.completion_write_save = false
		lvl.jump_to_scene = "res://stages/save_game_room/save_game_room.tscn"
