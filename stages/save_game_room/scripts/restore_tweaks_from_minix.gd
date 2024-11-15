extends Node

func _ready() -> void:
	if Scenes.previous_scene_path == "res://stages/extra/minix/minix.tscn":
		SettingsManager.load_tweaks()
		Data.values.erase("map_id")
		Data.values.erase("minix_continue")
