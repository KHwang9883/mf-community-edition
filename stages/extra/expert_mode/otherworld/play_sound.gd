extends Node

@export var sound: AudioStream

func sound_play() -> void:
	Audio.play_1d_sound(sound, false)
