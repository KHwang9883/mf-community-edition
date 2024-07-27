extends MenuSelection

func _handle_select() -> void:
	super()
	GlobalViewport.vp.get_camera_2d().position.y -= 480
	GlobalViewport.vp.get_camera_2d().position.x += 640
	await get_tree().physics_frame
	get_parent().move_selector(0)
	Scenes.current_scene.get_node("Menu/MainMenuControls").focused = true
	Scenes.current_scene.get_node("Tweaks/SubViewportContainer/SubViewport/Tweaks").focused = false
	
	SettingsManager.save_settings()
