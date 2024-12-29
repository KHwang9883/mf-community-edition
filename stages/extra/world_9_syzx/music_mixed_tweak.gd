extends Node

@onready var is_advanced = ProfileManager.current_profile.data.get("advanced_edition", false)

func _ready() -> void:
	var bgm_tweak: int = SettingsManager.get_tweak("bgm_as_in_version", 0)
	if bgm_tweak == 0:
		get_parent().index = 0 if is_advanced else 1
		
	get_parent().play_buffered.call_deferred()
