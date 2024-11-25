extends Label

func _ready() -> void:
	if SecretsManager.is_console_enabled() && !SettingsManager.get_tweak("console_enabled", false):
		text = "please restart your game!"
