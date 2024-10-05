extends Powerup

func collect() -> void:
	Thunder.add_lives.call_deferred(1)
	Audio.play_sound(preload("res://engine/objects/players/prefabs/sounds/1up.wav"), self)
	super()
