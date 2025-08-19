extends Sprite2D

@export var advance_map: Texture2D

@onready var _tweak = ProfileManager.current_profile.data.get("advanced_edition", false)

func _ready() -> void:
	if _tweak:
		texture = advance_map
