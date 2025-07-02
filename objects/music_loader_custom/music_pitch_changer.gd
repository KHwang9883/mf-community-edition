extends Node

@export var pitch_scale: float = 1.024
@export var affect_indexies: Array[bool] = [true]
@export var only_for_soundtrack_var: Array[bool] = [true, true, true, true]

@onready var _snd_tweak: int = SettingsManager.get_tweak("bgm_as_in_version", 0)
@onready var _pitch_tweak: bool = SettingsManager.get_tweak("copyright_free_ost", true)
@onready var _channel_id: int = $"..".channel_id
var _idx: int

func _ready() -> void:
	if !_pitch_tweak: return
	$"..".music_started.connect(_on_music_started)

func _on_music_started(index: int) -> void:
	_idx = -1
	await Audio.music_started
	_idx = index
	_on_order_changed()

func _on_order_changed() -> void:
	if affect_indexies.size() - 1 < _idx: return
	if affect_indexies[_idx] == false: return
	if only_for_soundtrack_var.get(_snd_tweak) == false: return
	print("Changing pitch of ", _idx)
	if !_channel_id in Audio._music_channels: return
	
	if Audio._music_channels[_channel_id].stream is AudioStreamMPT:
		Audio._music_channels[_channel_id].pitch_scale = 1.0 - (pitch_scale - 1.0)
		return
	Audio._music_channels[_channel_id].pitch_scale = pitch_scale
