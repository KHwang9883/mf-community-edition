extends Node2D

signal tweak_enabled
signal tweak_disabled

@export var inverted: bool = false
@onready var _tweak = ProfileManager.current_profile.data.get("advanced_edition", false)

func _ready() -> void:
	var _a = modulate.a
	modulate = Color.WHITE
	modulate.a = _a
	if inverted:
		_tweak = !_tweak
	if !_tweak:
		tweak_disabled.emit()
		hide()
		queue_free()
		return
	
	show()
	tweak_enabled.emit()
	reset_physics_interpolation()
	if Input.is_action_pressed(&"ui_page_up") && Console.debug_mode:
		ProfileManager.current_profile.data.advanced_edition = true
