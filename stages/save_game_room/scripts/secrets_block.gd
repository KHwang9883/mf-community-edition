extends Node2D

signal block_triggered

func _ready() -> void:
	if SecretsManager.is_console_enabled():
		show()
		block_triggered.emit()
	else:
		hide()
		process_mode = Node.PROCESS_MODE_DISABLED
