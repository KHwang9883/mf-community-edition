extends Node

@export var actual_scene_path: String

func _ready() -> void:
	$"..".level = actual_scene_path
