extends CanvasItem

func _ready() -> void:
	visible = SettingsManager.get_tweak("hint_signs", true)
