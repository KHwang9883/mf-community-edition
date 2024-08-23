extends Node2D

var map_id: int = 0
var map_names: Array[String]
var map_paths: Array[Node2D]
var current_map: MinixMap
var current_music_from_map: int = -1

var _continued: bool

@onready var music_loader_intro: Node = $"../../MusicLoaderIntro"
@onready var mario: CharacterBody2D = $"../../Mario"
@onready var maps: Node2D = $"../../Maps"
@onready var minix_score_loader: Node = $"../../MinixScoreLoader"
@onready var minix_controls: MenuItemsController = $MinixControls
@onready var control: Control = $"../Leaderboard/SubViewportContainer/SubViewport/Control/CanvasLayer/Title"

signal game_started

func _ready() -> void:
	Scenes.custom_scenes.minix_node = self
	for i in maps.get_children():
		if !i is MinixMap:
			continue
		i.hide()
		map_names.append(i.map_name)
		map_paths.append(i)
	var _minix_music = minix_score_loader.score_values.settings.minix_music
	if !is_nan(int(_minix_music)) && len(map_names) - 1 >= int(_minix_music):
		current_music_from_map = max(-1, int(_minix_music))
	if "minix_continue" in Data.values:
		modulate.a = 0.0
		_continued = true
		minix_controls.focused = false
		map_id = Data.values.minix_continue
		Data.values.map_id = map_id
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
			i.reset_physics_interpolation()
			i.show()
			#Thunder._disconnect(game_started, i.queue_free)
			if mario:
				mario.global_position = current_map.get_node("MarioPos").global_position
				mario.reset_physics_interpolation()
				mario.underwater.max_falling_speed_override = 500
				mario.lives = current_map.life_count
			continue
		i.position.y = -999999
		i.reset_physics_interpolation()
		i.hide()
		#Thunder._connect(game_started, i.queue_free, Node.CONNECT_ONE_SHOT)


func start_game() -> void:
	Audio.stop_music_channel(0, true)
	_music.call_deferred()
	var tw = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tw.tween_property(self, "modulate:a", 0.0, 0.5)
	
	mario.completed = false
	
	control.map_id = map_id + 1
	control._update_map.call_deferred(true)
	(func():
		game_started.emit()
	).call_deferred()


func _music() -> void:
	var map: MinixMap = current_map if current_music_from_map == -1 else map_paths[current_music_from_map]
	var music_loader = map.get_node("MusicLoader")
	if map.start_again_on_replay || !_continued:
		music_loader.index = randi_range(0, len(music_loader.current_music) - 1)
		music_loader.play_buffered()
