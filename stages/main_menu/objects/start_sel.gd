extends "res://engine/scenes/main_menu/scripts/start_selection.gd"

const MESSAGE_BLOCK = preload("res://engine/objects/bumping_blocks/message_block/message_block.wav")

func _handle_select(mouse_input = false) -> void:
	if starting: return
	if get_parent().has_meta(&"has_update"):
		get_parent().remove_meta(&"has_update")
		Scenes.current_scene.get_node("UpdateConfirmModal/Control").toggle()
		var _snd = CharacterManager.get_sound_replace(MESSAGE_BLOCK, MESSAGE_BLOCK, "message_box", false)
		Audio.play_1d_sound(_snd, true, {ignore_pause = true})
		return
	super(mouse_input)
