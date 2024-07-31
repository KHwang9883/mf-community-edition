extends Node2D


@onready var quality: SettingsManager.QUALITY = SettingsManager.settings.quality
@onready var QUALITY = SettingsManager.QUALITY

func _ready() -> void:
	SettingsManager.settings_updated.connect(_update_visibility)
	_update_visibility()


func _update_visibility() -> void:
	quality = SettingsManager.settings.quality
	modulate.v = 1.0 if bool(quality) else 0.7
