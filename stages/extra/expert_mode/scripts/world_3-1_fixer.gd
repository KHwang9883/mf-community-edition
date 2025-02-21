extends Node

const APPLEUSE = preload("res://stages/extra/click_bonus_game/sfx/appleuse.ogg")
@export var path: String = "res://stages/world_3/expert_level_3-1.tscn"

func _ready() -> void:
	if !ProfileManager.current_profile.has_completed(path):
		ProfileManager.current_profile.complete_level(path)
		ProfileManager.save_current_profile()
	
	Scenes.custom_scenes.game_over.custom_resume_scene = ""
	
	await get_tree().create_timer(0.6, false).timeout
	var toadd: int = 0
	if Data.values.lives > 4:
		toadd = Data.values.lives - 4
	if "lavarun_lives" in Data.technical_values:
		Data.values.lives = Data.technical_values.lavarun_lives
		Data.values.lives += toadd
		Data.technical_values.erase("lavarun_lives")
	Audio.play_1d_sound(APPLEUSE, true, { ignore_pause = true })

	var tw = create_tween().set_parallel()
	tw.tween_property($Congratulations, "modulate:a", 1.0, 1.0)
	
	for i in 3:
		await get_tree().create_timer(0.6, false, false, true).timeout
		Thunder.add_lives(1, Thunder._current_player)
		Audio.play_1d_sound(preload("res://engine/objects/players/prefabs/sounds/1up.wav"))
