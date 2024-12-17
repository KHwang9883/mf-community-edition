extends Node

func _ready() -> void:
	SettingsManager.load_tweaks()
	if Scenes.previous_scene_path == "res://stages/extra/minix/minix.tscn":
		Data.values.erase("map_id")
		Data.values.erase("minix_continue")
