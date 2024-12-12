extends Label

@export var text_keyboard: String = "to select a level, use corresponding number buttons."
@export var text_joypad: String = "to select a level, press up button."

func _ready() -> void:
	update_text()
	SettingsManager.settings_saved.connect(update_text)


func update_text() -> void:
	if SettingsManager.device_keyboard:
		text = text_keyboard
	else:
		text = text_joypad
