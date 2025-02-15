extends Node

func _ready() -> void:
	if Data.values.get("goto_human_lab"):
		Scenes.current_scene.jump_to_scene = "res://stages/extra/human_lab/human_lab_map.tscn"
	
