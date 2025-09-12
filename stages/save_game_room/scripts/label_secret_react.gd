extends "res://engine/scenes/save_game_room/scripts/saved_level_label.gd"

@export var secret_name: String
@export var secret_progress_id: String
@export var secret_kevin_name: String
@export var secret_standalone: String
@export var secret_kevin_standalone: String

func _ready() -> void:
	super()
	if !_label_ready():
		remove_theme_color_override.call_deferred(&"font_color")

func _label_ready() -> bool:
	# Standalone Secret
	
	if secret_kevin_standalone:
		var secr_1 = SecretsManager.get_secret(secret_kevin_standalone)
		if secr_1 && typeof(secr_1) == TYPE_BOOL:
			color_kevin()
			return true
	if secret_standalone:
		var secr_2 = SecretsManager.get_secret(secret_standalone)
		if secr_2 && typeof(secr_2) == TYPE_BOOL:
			color_green()
			return true
	
	# Progressed Secret (old behavior from 2.0.1 and below)
	if !secret_name:
		return false
	var secret = SecretsManager.get_secret(secret_name)
	if secret_kevin_name:
		var secr_kev = SecretsManager.get_secret(secret_kevin_name)
		if secr_kev && typeof(secr_kev) == TYPE_ARRAY && secret_progress_id in secr_kev:
			color_kevin()
			return true
			
	if typeof(secret) != TYPE_ARRAY:
		return false
	if secret_progress_id in secret:
		color_green()
		return true
	return false


func color_kevin() -> void:
	add_theme_color_override(&"font_color", Color("#b16dff"))

func color_green() -> void:
	add_theme_color_override(&"font_color", Color.LIGHT_GREEN)
