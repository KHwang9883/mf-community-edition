extends Node

@export var sound: AudioStream
@export var replaced_sound_name: String
@export var replaced_sound_is_suit: bool

func sound_play() -> void:
	Audio.play_1d_sound(sound, false)

func replaced_sound_play() -> void:
	var _sfx = CharacterManager.get_sound_replace(sound, sound, replaced_sound_name, replaced_sound_is_suit)
	Audio.play_1d_sound(_sfx, false)
