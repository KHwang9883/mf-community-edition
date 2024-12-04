extends Node2D

@export var inverted: bool = false
@onready var _tweak = ProfileManager.current_profile.data.get("advanced_edition", false)

func _ready() -> void:
	var _a = modulate.a
	modulate = Color.WHITE
	modulate.a = _a
	if inverted:
		_tweak = !_tweak
	if !_tweak:
		hide()
		queue_free()
