extends Node2D

var map_id: int = 0
var map_names: Array[String]
var map_paths: Array[Node2D]
var current_map: MinixMap
var current_music_from_map: MinixMap = null

var _continued: bool

@onready var music_loader_intro: Node = $"../../MusicLoaderIntro"
@onready var mario: CharacterBody2D = $"../../Mario"
@onready var maps: Node2D = $"../../Maps"
@onready var minix_score_loader: Node = $"../../MinixScoreLoader"
@onready var minix_controls: MenuItemsController = $MinixControls

signal game_started

func _ready() -> void:
	for i in maps.get_children():
		if !i is MinixMap:
			continue
		map_names.append(i.map_name)
		map_paths.append(i)
	var _minix_music: String = minix_score_loader.score_values.settings.minix_music
	if map_names.has(_minix_music):
		var i: int = map_names.find(_minix_music)
		current_music_from_map = map_paths[i]
	if "minix_continue" in Data.values:
		modulate.a = 0.0
		_continued = true
		minix_controls.focused = false
		_on_map_changed_to(Data.values.minix_continue)
		start_game()
	else:
		mario.completed = true
		$"../../CanvasLayer".hide()
		music_loader_intro.play_buffered()
		if "map_id" in Data.values:
			map_id = Data.values.map_id
		_on_map_changed_to(map_id)


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
	_music.call_deferred()
	var tw = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tw.tween_property(self, "modulate:a", 0.0, 0.5)
	
	mario.completed = false
	Data.values.map_id = map_id
	game_started.emit()


func _music() -> void:
	var map: MinixMap = current_map if current_music_from_map == null else current_music_from_map
	var music_loader = map.get_node("MusicLoader")
	if map.start_again_on_replay || !_continued:
		music_loader.index = randi_range(0, len(music_loader.current_music) - 1)
		music_loader.play_buffered()
