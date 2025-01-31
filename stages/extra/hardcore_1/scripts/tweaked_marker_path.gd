extends Node

@export_file("*.tscn", "*.scn") var new_level_path: String

@onready var _tweak: bool = SettingsManager.get_tweak("remade_levels", true)
@onready var _warn_tweak: bool = SettingsManager.get_tweak("show_warning_on_revamped_levels", true)
@onready var revamp_warning: CanvasLayer = $RevampWarning

func _ready() -> void:
	if new_level_path && _tweak:
		if _warn_tweak:
			revamp_warning.toggle()
			return
		get_parent().level = new_level_path
