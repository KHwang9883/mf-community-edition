extends CanvasModulate

@onready var _tweak = ProfileManager.current_profile.data.get("advanced_edition", false)

func _ready() -> void:
	if _tweak:
		color = Color("#1e1e1e")
