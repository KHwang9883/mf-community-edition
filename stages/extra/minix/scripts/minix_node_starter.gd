extends Node2D

var map_id: int = 0
var map_names: Array[String]
var map_paths: Array[Node2D]
var current_map: MinixMap
var current_music_from_map: int = -1

var _continued: bool

@onready var music_loader_intro: Node = $"../../MusicLoaderIntro"
@onready var mario: Player = Thunder._current_player
@onready var maps: Node2D = $"../../Maps"
@onready var minix_score_loader: Node = $"../../MinixScoreLoader"
@onready var minix_controls: MenuItemsController = $MinixControls
@onready var control: Control = $"../Leaderboard/SubViewportContainer/SubViewport/Control/CanvasLayer/Title"
var leaderboard_client: LeaderboardClient

signal game_started

func _ready() -> void:
	leaderboard_client = get_node_or_null(^"../../LeaderboardClient")
	Scenes.custom_scenes.minix_node = self
	SettingsManager.set_tweak("life_every_2_mil_score", false)
	SettingsManager.set_tweak("stomping_combo", false)
	SettingsManager.set_tweak("super_jump_bug", false)
	
	#Scenes.current_scene.stage_ready.connect(func():
		#if "minix_continue" in Data.values:
			#return
		#
	#, CONNECT_ONE_SHOT)
	
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
		minix_controls.set_deferred("focused", true)
	
	SettingsManager.show_mouse()


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
				mario.suit.physics_config.set("swim_max_falling_speed", 500)
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

	if leaderboard_client:
		leaderboard_client.reset_integrity()
		leaderboard_client.version = ProjectSettings.get_setting("application/thunder_settings/version", 0)
		leaderboard_client.game = "MINIX"

	mario.completed = false
	SettingsManager.hide_mouse()
	
	control.map_id = map_id + 1
	control._update_map.call_deferred(true)
	for i in len(map_paths):
		if i != map_id && i != current_music_from_map:
			map_paths[i].queue_free()
		
	(func():
		game_started.emit()
	).call_deferred()


func _music() -> void:
	var map: MinixMap = current_map if current_music_from_map == -1 else map_paths[current_music_from_map]
	var music_loader = map.get_node("MusicLoader")
	if !(map.start_again_on_replay || !_continued): return
	
	var _prev_pool: Array = Data.technical_values.get("_minix_random_music_pool", [])
	var _prev_map: String = Data.technical_values.get("_minix_last_map", "")
	var new_random: int = -1
	
	if _prev_map != map.map_name || _prev_pool.is_empty():
		var music_pool: Array = []
		music_pool.resize(len(music_loader.current_music))
		for i in len(music_pool):
			music_pool[i] = i
		_prev_pool = music_pool
		Data.technical_values._minix_last_map = map.map_name
	
	new_random = _prev_pool.pop_at(_prev_pool.find(randi_range(0, len(_prev_pool))))
		
	Data.technical_values._minix_random_music_pool = _prev_pool
	
	music_loader.index = new_random
	music_loader.play_buffered()


func _on_time_added(time: int) -> void:
	if leaderboard_client:
		leaderboard_client.track_time(time)
