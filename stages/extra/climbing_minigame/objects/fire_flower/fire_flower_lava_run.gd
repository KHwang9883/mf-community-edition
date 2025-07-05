extends Powerup

func collect() -> void:
	if 'lavarun_difficulty' in Data.values && Data.values['lavarun_difficulty'] > 3:
		super()
		return
	if CharacterManager.get_suit(to_suit).name == Thunder._current_player_state.name:
		Thunder.add_lives.call_deferred(1)
		var _sfx = CharacterManager.get_sound_replace(Data.LIFE_SOUND, Data.LIFE_SOUND, "1up", false)
		Audio.play_sound(_sfx, self)
	super()
