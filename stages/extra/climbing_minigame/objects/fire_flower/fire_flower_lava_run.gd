extends Powerup

func collect() -> void:
	if 'lavarun_difficulty' in Data.values && Data.values['lavarun_difficulty'] > 3:
		super()
		return
	Thunder.add_lives.call_deferred(1)
	Audio.play_sound(preload("res://engine/objects/players/prefabs/sounds/1up.wav"), self)
	super()
