@tool
extends "res://engine/objects/warps/pipe_in.gd"

@export_file("*.tscn", "*.scn") var warp_to_remade_scene_tweak: String

func _ready() -> void:
	super()
	if Engine.is_editor_hint(): return
	if warp_to_remade_scene_tweak != "" && SettingsManager.get_tweak("remade_levels", true):
		warp_to_scene = warp_to_remade_scene_tweak
