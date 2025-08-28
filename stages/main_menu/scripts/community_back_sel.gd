extends MenuSelection


func _handle_select(mouse_input: bool = false) -> void:
	super(mouse_input)
	get_parent().focused = false
	var modal = Scenes.current_scene.get_node_or_null("Menu/MainMenuControls")
	if !modal: return
	var control = $"../.."
	control.get_node("AnimationPlayer").play_backwards("fade")
	await get_tree().physics_frame
	modal.focused = true
