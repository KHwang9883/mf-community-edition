extends "res://engine/scenes/save_game_room/scripts/saved_level_label.gd"

@export var secret_name: String
@export var secret_progress_id: String
@export var secret_kevin_name: String

func _ready() -> void:
	super()
	var secret = SecretsManager.get_secret(secret_name)
	if secret_kevin_name:
		var secr_kev = SecretsManager.get_secret(secret_kevin_name)
		if secr_kev && typeof(secr_kev) == TYPE_ARRAY && secret_progress_id in secr_kev:
			add_theme_color_override(&"font_color", Color("#b16dff"))
			return
			
	if typeof(secret) != TYPE_ARRAY:
		return
	if secret_progress_id in secret:
		add_theme_color_override(&"font_color", Color.LIGHT_GREEN)
