extends Node2D

const map_names: Array[String] = [
	"classic",
	"super mario playgrounds",
	"super mario underwater"
]

var map_id: int = 0

@onready var map_paths: Array[Node2D] = [
	$"../../Maps/classic",
	$"../../Maps/playgrounds",
	$"../../Maps/underwater"
]
@onready var map_lives: Array[int] = [
	1, 3, 1
]
@onready var mario: CharacterBody2D = $"../../Mario"
@onready var life_1: Node2D = $"../../CanvasLayer/Node2D"
@onready var life_2: Node2D = $"../../CanvasLayer/Node2D2"
@onready var life_3: Node2D = $"../../CanvasLayer/Node2D3"

func _ready() -> void:
	_on_map_changed_to(map_id)


func _on_map_changed_to(_id: int) -> void:
	var map = map_paths[_id]
	map.visible = true
	var mario = Thunder._current_player
	for i in map_paths:
		if i.get_instance_id() == map.get_instance_id():
			i.position.y = 0
			if mario:
				mario.global_position = map.get_node("MarioPos").global_position
				mario.underwater.max_falling_speed_override = 500
			continue
		i.position.y = -999999


func music() -> void:
	var map = map_paths[map_id]
	var music_loader = map.get_node("MusicLoader")
	music_loader.index = randi_range(0, len(music_loader.current_music) - 1)
	music_loader.play_buffered()
