extends Node2D

signal block_triggered

func _ready() -> void:
	if SettingsManager.get_tweak("console_enabled", false):
		show()
	else:
		hide()
		block_triggered.emit()
		process_mode = Node.PROCESS_MODE_DISABLED
