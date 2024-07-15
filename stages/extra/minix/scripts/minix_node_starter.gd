extends Node2D

var map_id: int = 0
var map_names: Array[String]
var map_paths: Array[Node2D]
var current_map: MinixMap

@onready var mario: CharacterBody2D = $"../../Mario"
@onready var maps: Node2D = $"../../Maps"

signal game_started

func _ready() -> void:
	mario.completed = true
	$"../../CanvasLayer".hide()
	for i in maps.get_children():
		if !i is MinixMap:
			continue
		map_names.append(i.map_name)
		map_paths.append(i)


func _on_map_changed_to(_id: int) -> void:
	current_map = map_paths[_id]
	current_map.visible = true
	for i in map_paths:
		if i.get_instance_id() == current_map.get_instance_id():
			i.position.y = 0
			if mario:
				mario.global_position = current_map.get_node("MarioPos").global_position
				mario.underwater.max_falling_speed_override = 500
				mario.lives = current_map.life_count
			continue
		i.position.y = -999999


func start_game() -> void:
	Audio.stop_music_channel(0, true)
	_music()
	var tw = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tw.tween_property(self, "modulate:a", 0.0, 0.5)
	
	mario.completed = false
	game_started.emit()
	Data.values.map_id = map_id


func _music() -> void:
	var music_loader = current_map.get_node("MusicLoader")
	music_loader.index = randi_range(0, len(music_loader.current_music) - 1)
	music_loader.play_buffered()
