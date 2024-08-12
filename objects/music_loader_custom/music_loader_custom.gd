extends "res://engine/objects/core/music_loader/music_loader.gd"

@export_category("Tweaks")
@export var tweaked_completion_music: Resource = preload("res://music/complete_tweaked.ogg")
@export var ignore_fade_in_tweak: bool = false
## ver 2.16 / 4.4 soundtrack
@export var music_var_1: Array[Resource]
## ver 5.05 soundtrack
@export var music_var_2: Array[Resource]
## ver 7.02-31 soundtrack
@export var music_var_3: Array[Resource]
@export_group("Tweaked Music Settings")
@export var var_1_volume_db: Array[float] = [0.0]
@export var var_1_start_from_sec: Array[float] = [0.0]
@export var var_2_volume_db: Array[float] = [0.0]
@export var var_2_start_from_sec: Array[float] = [0.0]
@export var var_3_volume_db: Array[float] = [0.0]
@export var var_3_start_from_sec: Array[float] = [0.0]
@export_group("Boss Battle Music", "boss_music")
## ver 2.16 / 4.4 soundtrack
@export var boss_music_var_1: Resource
## ver 5.05 soundtrack
@export var boss_music_var_2: Resource
## ver 7.02-31 soundtrack
@export var boss_music_var_3: Resource
@export var boss_music_volume_db: Array[float] = [0.0]
@export var boss_music_start_from_sec: Array[float] = [0.0]

var current_music: Array[Resource]

func _ready():
	# Achievements!
	var _level = Scenes.current_scene
	if _level is Level && ("res://stages/world_" in _level.jump_to_scene || "res://stages/cutscenes/ending" in _level.jump_to_scene):
		(func():
			var pl = Thunder._current_player
			while !is_instance_valid(pl):
				await get_tree().physics_frame
			pl.damaged.connect(func():
				ProfileManager.current_profile.data.damaged = true
			)
			pl.died.connect(func():
				ProfileManager.current_profile.data.died = true
			)
		).call_deferred()
	
	
	# Soundtrack Stuff
	if SettingsManager.get_tweak("alt_completion_music", false) && Scenes.current_scene is Level:
		Scenes.current_scene.completion_music = tweaked_completion_music
	
	var bgm_tweak: int = SettingsManager.get_tweak("bgm_as_in_version", 0)
	if bgm_tweak >= 1 && bgm_tweak <= 3:
		var _set: bool = _bgm_tweak(bgm_tweak)
		if _set:
			super(); return
	current_music = music.duplicate()
	super()


func _bgm_tweak(which: int) -> bool:
	var bowser_trigger: Path2D = Scenes.current_scene.get_node_or_null(^"BowserTrigger")
	if bowser_trigger && get("boss_music_var_" + str(which)):
		bowser_trigger.boss_music = get("boss_music_var_" + str(which))
		if len(boss_music_volume_db) > which - 1:
			bowser_trigger.boss_music_volume = boss_music_volume_db[which - 1]
		if len(boss_music_start_from_sec) > which - 1:
			bowser_trigger.boss_music_start_from_sec = boss_music_start_from_sec[which - 1]
	if get("music_var_" + str(which)).size() > 0:
		current_music = get("music_var_" + str(which)).duplicate()
		volume_db = get("var_%s_volume_db" % str(which)).duplicate()
		start_from_sec = get("var_%s_start_from_sec" % str(which)).duplicate()
		return true
	return false


func _change_music(ind: int, ch_id: int) -> void:
	if current_music.size() <= ind: return
	var options = [
		current_music[ind],
		ch_id,
		{
			"ignore_pause": true, 
			"volume": volume_db[ind] if volume_db.size() >= ind else 0.0,
			"start_from_sec": start_from_sec[ind] if start_from_sec.size() >= ind else 0.0
		}
	]
	if play_immediately:
		music_started.emit(ind)
		var _trans = TransitionManager.current_transition
		if _crossfade && is_instance_valid(_trans) && _trans.name == "crossfade_transition":
			await _trans.end
		var player = await Audio.play_music(options[0], options[1], options[2], play_globally)
		(func():
			if play_globally && player:
				player.set_meta(&"play_when_scene_changed", true)
		).call_deferred()
		is_paused = false
		_fade_in_tweak.call_deferred(player, ind)
	else:
		music_buffered.emit(ind)
		buffer = options

func play_or_buffer(ind: int = index, ch_id: int = channel_id) -> void:
	if !Audio._music_channels.has(ch_id) || !is_instance_valid(Audio._music_channels[ch_id]):
		return
	if !buffer.is_empty():
		buffer[0] = current_music[ind]
		buffer[1] = ch_id
	
	index = ind

func play_buffered(buffered_to_play: Array = buffer) -> bool:
	if buffered_to_play.is_empty(): return false
	if buffered_to_play.size() < 3: return false
	if is_paused:
		Audio.stop_all_musics()
	var _trans = TransitionManager.current_transition
	if _crossfade && is_instance_valid(_trans) && _trans.name == "crossfade_transition":
		await _trans.end
	var player = await Audio.play_music(buffered_to_play[0], buffered_to_play[1], buffered_to_play[2], play_globally)
	music_resumed_buffered.emit()
	_fade_in_tweak.call_deferred(player, current_music.find(buffered_to_play[0]))
	buffered_to_play = []
	is_paused = false
	return true


func _fade_in_tweak(player, ind: int) -> void:
	if !SettingsManager.get_tweak("bgm_fade_in_bug_emulation", false):
		return
	await get_tree().create_timer(0.017, true, false, true).timeout
	if ind == 0 && !ignore_fade_in_tweak:
		player.volume_db = -59
		var to_vol = volume_db[ind] if volume_db.size() >= ind else 0.0
		Audio.fade_music_1d_player(player, to_vol, 0.5 / Engine.time_scale, Tween.TRANS_CUBIC, false, Tween.EASE_OUT)


func set_index(ind: int) -> void:
	index = ind
