@tool
extends MarkerSpace

@export var advance_progress_prefix: String
@export var advance_progress_level: String

func _ready() -> void:
	if !Engine.is_editor_hint():
		var _tweak = ProfileManager.current_profile.data.get("advanced_edition", false)
		if _tweak:
			if advance_progress_prefix:
				progress_title_prefix = advance_progress_prefix
			if advance_progress_level:
				progress_title_level = advance_progress_level
	super()
