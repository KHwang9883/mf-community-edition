extends "res://engine/objects/players/player.gd"

func _ready() -> void:
	death_music_override = CharacterManager.get_voice_line("fall")
	super()
