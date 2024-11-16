extends "res://engine/components/progress_continue/scripts/progress_continue_screen.gd"

@onready var cursed_preview: AnimatedSprite2D = $CursedPreview

func suspended_game_logic() -> void:
	var player: Player = Thunder._current_player
	player.no_movement = true
	player.hide()

	profile = ProfileManager.profiles.suspended.data
	scene = profile.scene
	var label_text: String = profile.title_prefix.replacen("\\n", "
")
	label_text += profile.title_level
	level_label.text = label_text
	if profile.get(&"saved_player_state"):
		var suit_frames: SpriteFrames = CharacterManager.get_suit(profile.saved_player_state).animation_sprites
		state_preview.sprite_frames = suit_frames
		state_preview.play(&"walk")
		if profile.saved_profile_data.get(&"kevin_mode_enabled"):
			cursed_preview.sprite_frames = suit_frames
			cursed_preview.visible = true
			cursed_preview.play(&"walk")
	Scenes.custom_scenes.pause.open_blocked = true
	
	animation_player.play(&"init")
	toggle()
