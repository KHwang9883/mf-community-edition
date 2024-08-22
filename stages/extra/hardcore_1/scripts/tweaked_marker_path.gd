extends Node

@export_file("*.tscn", "*.scn") var new_level_path: String

@onready var _tweak: bool = SettingsManager.get_tweak("remade_levels", true)

func _ready() -> void:
	if new_level_path && _tweak:
		get_parent().level = new_level_path
