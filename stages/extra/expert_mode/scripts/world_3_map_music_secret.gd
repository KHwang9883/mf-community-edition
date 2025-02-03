extends Node

@export_file("*.tscn", "*.scn") var trigger_on: String
@onready var music_loader: Node = $"../MusicLoader"

func _ready() -> void:
	if Scenes.previous_scene_path == trigger_on:
		music_loader.index = 1
	music_loader.play_buffered()
