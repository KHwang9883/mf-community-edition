extends Label

@onready var _tweak = ProfileManager.current_profile.data.get("advanced_edition", false)

func _ready() -> void:
	var _str = "*" if _tweak else ""
	text = text % _str
