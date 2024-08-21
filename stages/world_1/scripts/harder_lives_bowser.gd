extends Node

@onready var _tweak: bool = SettingsManager.get_tweak("harder_level_design", false)

func _ready() -> void:
	if _tweak:
		get_parent().health = 5
