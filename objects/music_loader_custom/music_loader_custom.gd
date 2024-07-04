extends "res://engine/objects/core/music_loader/music_loader.gd"

@export_category("Tweaks")
@export var tweaked_completion_music: Resource = preload("res://music/complete_tweaked.ogg")
## ver 2.16 soundtrack
@export var music_var_1: Array[Resource]
## ver 5.05 soundtrack
@export var music_var_2: Array[Resource]
## ver 7.02-31 soundtrack
@export var music_var_3: Array[Resource]
@export var ignore_fade_in_tweak: bool = false

var current_music: Array[Resource]

func _ready():
	match SettingsManager.get_tweak("bgm_as_in_version", 0):
		1:
			if music_var_1.size() > 0:
				current_music = music_var_1.duplicate()
				super(); return
		2:
			Scenes.current_scene.completion_music = tweaked_completion_music
			if music_var_2.size() > 0:
				current_music = music_var_2.duplicate()
				super(); return
		3:
			Scenes.current_scene.completion_music = tweaked_completion_music
			if music_var_3.size() > 0:
				current_music = music_var_3.duplicate()
				super(); return
	current_music = music.duplicate()
	super()

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
	var player = await Audio.play_music(buffered_to_play[0], buffered_to_play[1], buffered_to_play[2], play_globally)
	music_resumed_buffered.emit()
	_fade_in_tweak.call_deferred(player, current_music.find(buffered_to_play[0]))
	buffered_to_play = []
	is_paused = false
	return true


func _fade_in_tweak(player, ind: int) -> void:
	if !SettingsManager.get_tweak("bgm_fade_in_bug_emulation", false):
		return
	await get_tree().create_timer(0.033, true, false, true).timeout
	if ind == 0 && !ignore_fade_in_tweak:
		player.volume_db = -59
		var to_vol = volume_db[ind] if volume_db.size() >= ind else 0.0
		Audio.fade_music_1d_player(player, to_vol, 0.5, Tween.TRANS_CUBIC, false, Tween.EASE_OUT)
