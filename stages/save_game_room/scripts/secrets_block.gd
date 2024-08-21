extends Node2D

func _ready() -> void:
	if SettingsManager.get_tweak("console_enabled", false):
		show()
	else:
		hide()
		process_mode = Node.PROCESS_MODE_DISABLED
