extends TextureRect

const HAMMER_ITEM = preload("res://objects/_hammer_item/hammer_item.tscn")
const INCORRECT = preload("res://engine/components/ui/_sounds/incorrect.wav")

func activate() -> bool:
	var worked: bool
	var pl: Player = Thunder._current_player
	if pl:
		var ham = HAMMER_ITEM.instantiate()
		ham.score = 0
		ham.appear_distance = 0
		ham.transform = pl.transform
		Scenes.current_scene.add_child(ham)
		ham.collect()
		ham.reset_physics_interpolation.call_deferred()
		ham.process_mode = Node.PROCESS_MODE_INHERIT
		worked = true
	
	if !worked:
		var inc_sfx = CharacterManager.get_sound_replace(INCORRECT, INCORRECT, "menu_failure", false)
		Audio.play_1d_sound(inc_sfx, false, {ignore_pause = true})
	
	return worked
