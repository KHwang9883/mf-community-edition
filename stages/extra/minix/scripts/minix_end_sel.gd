extends MenuSelection


func _handle_select() -> void:
	super()
	Scenes.goto_scene(ProjectSettings.get("application/thunder_settings/main_menu_path"))
