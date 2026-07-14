extends "res://engine/objects/core/music_loader/music_loader.gd"

const MUSIC_PITCH_CHANGER = preload("res://objects/music_loader_custom/music_pitch_changer.tscn")
const PITCH_PREFIXES: Array = ["smw2-", "smw-", "smas-", "smrpg-", "smb-", "smb3-", "save_g", "smb_", "smb1"]

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
var is_squario: bool
var bgm_tweak: int

func _ready():
	# Achievements!
	_ready_achievements()
	
	# --- Tweaks stuff ---
	_ready_mus_tweaks()
	
	# Soundtrack Stuff
	_ready_mus_hacks()
	
	super()


func _ready_achievements() -> void:
	if ProfileManager.current_profile.data.get("star_world"):
		return
	var _level = Scenes.current_scene
	if !_level is Level: return
	if !"res://stages/world_" in _level.jump_to_scene && !"res://stages/cutscenes/ending" in _level.jump_to_scene:
		return
	
	(func():
		var pl = Thunder._current_player
		var _i: int = 0
		while !is_instance_valid(pl) && _i < 200:
			await get_tree().physics_frame
			_i += 1
			if _i >= 199:
				return
		
		var frog_failed: Callable = (func():
			if !Data.values.get("frog_challenge", false):
				return
			SecretsManager.show_failure("frog challenge failed!")
			Data.values.erase("frog_challenge")
		)
		pl.damaged.connect(func():
			if Data.values.get("frog_challenge", false) && ProfileManager.current_profile.data.get("damaged", false):
				frog_failed.call()
				#SecretsManager.show_failure("no hit run is now invalid!", "achievement failed")
			ProfileManager.current_profile.data.damaged = true
		)
		pl.died.connect(func():
			if Data.values.get("frog_challenge", false):
				frog_failed.call()
				#SecretsManager.show_failure("no deaths run is now invalid!", "achievement failed")
			ProfileManager.current_profile.data.died = true
		)
		if Data.values.get("frog_challenge", false):
			if !Thunder._current_player.no_movement && Thunder._current_player.suit.name != &"frog":
				frog_failed.call()
			pl.suit_changed.connect(frog_failed.unbind(1))
	).call_deferred()


func _ready_mus_tweaks() -> void:
	if SettingsManager.get_tweak("pitch_music_everywhere", false) && !has_node("MusicPitchChanger"):
		var _pitch_changer = MUSIC_PITCH_CHANGER.instantiate()
		add_child(_pitch_changer, true)
	
	if SettingsManager.get_tweak("amiga_ntsc_pitch", false):
		Thunder._connect(music_started, func(_index: int):
			await Audio.music_started
			(func():
				if !channel_id in Audio._music_channels: return
				if !is_instance_valid(Audio._music_channels[channel_id]): return
				
				if Audio._music_channels[channel_id].stream is AudioStreamMPT:
					var _res_path: String = Audio._music_channels[channel_id].stream.resource_path
					if _res_path.ends_with(".mod") || "u_feel_it" in _res_path:
						print("Changing AMIGA pitch of ", _index)
						var playback: AudioStreamPlaybackMPT = Audio._music_channels[channel_id].get_stream_playback()
						playback.set_pitch_factor(1.00917)
			).call_deferred()
		)
	
	if SettingsManager.get_tweak("original_snes_pitch", false):
		Thunder._connect(music_started, func(_index: int):
			await Audio.music_started
			(func():
				if !channel_id in Audio._music_channels: return
				if !is_instance_valid(Audio._music_channels[channel_id]): return false
				if !_snes_pitch_check(Audio._music_channels[channel_id].stream):
					return
				
				if Audio._music_channels[channel_id].stream is AudioStreamMPT:
					print("Changing SNES pitch of ", _index)
					var playback: AudioStreamPlaybackMPT = Audio._music_channels[channel_id].get_stream_playback()
					playback.set_pitch_factor(0.976)
				else:
					Audio._music_channels[channel_id].pitch_scale = 0.976
			).call_deferred()
		)


func _ready_mus_hacks() -> void:
	var _level = Scenes.current_scene
	if SettingsManager.get_tweak("alt_completion_music", false) && _level is Level:
		_level.completion_music = tweaked_completion_music
		_level.DEFAULT_COMPLETION = tweaked_completion_music
	
	var scene_path: String = _level.scene_file_path
	is_squario = _level is Stage2D && "/extra/squario" in scene_path
	bgm_tweak = SettingsManager.get_tweak("bgm_as_in_version", 0)
	if is_squario:
		bgm_tweak = int(SettingsManager.get_tweak("squario_music", 1))
		if bgm_tweak == 2:
			music_var_2 = music_var_1
			boss_music_var_2 = boss_music_var_1
			var_2_volume_db = var_1_volume_db
		if bgm_tweak != 0 && _level is Level && SecretsManager.has_meta(&"squario_lvl_complete"):
			_level.completion_music = SecretsManager.get_meta(&"squario_lvl_complete")
			_level.DEFAULT_COMPLETION = _level.completion_music
			_level.completion_music_delay_sec = 3.0
	
	if bgm_tweak >= 1 && bgm_tweak <= 3:
		var _set: bool = _bgm_tweak(bgm_tweak)
		if _set:
			return
	current_music = music.duplicate()


func _bgm_tweak(which: int) -> bool:
	var bowser_trigger: Path2D = Scenes.current_scene.get_node_or_null(^"BowserTrigger")
	if bowser_trigger && get("boss_music_var_" + str(which)):
		bowser_trigger.boss_music = get("boss_music_var_" + str(which))
		if len(boss_music_volume_db) > which - 1:
			bowser_trigger.boss_music_volume = boss_music_volume_db[which - 1]
		if len(boss_music_start_from_sec) > which - 1:
			bowser_trigger.boss_music_start_from_sec = boss_music_start_from_sec[which - 1]
		if is_squario && bgm_tweak == 1:
			bowser_trigger.boss_music_subsong = 1
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
			&"ignore_pause": !can_pause, 
			&"volume": volume_db[ind] if volume_db.size() >= ind else 0.0,
			&"start_from_sec": start_from_sec[ind] if start_from_sec.size() >= ind else 0.0,
			&"subsong": subsong[ind] if subsong.size() >= ind else 0,
		}
	]
	if is_squario && bgm_tweak == 1:
		options[2].subsong = 1
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
	await get_tree().create_timer(0.015, true, false, true).timeout
	if ind == 0 && !ignore_fade_in_tweak && is_instance_valid(player):
		player.volume_db = -59
		var to_vol = volume_db[ind] if volume_db.size() >= ind else 0.0
		Audio.fade_music_1d_player(player, to_vol, 0.5 / Engine.time_scale, Tween.TRANS_CUBIC, false, Tween.EASE_OUT)


func _snes_pitch_check(stream: AudioStream) -> bool:
	if !is_instance_valid(stream): return false
	var filename: String
	if stream is AudioStreamSynchronized:
		filename = stream.get_sync_stream(0).resource_path.get_file().left(6)
	else:
		filename = stream.resource_path.get_file().left(6)
	var _allow: bool
	for i in PITCH_PREFIXES:
		if i in filename:
			_allow = true
			break
	return _allow


func set_index(ind: int) -> void:
	index = ind
