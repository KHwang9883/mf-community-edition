extends Node2D

@export var inverted: bool = false
@onready var _tweak = ProfileManager.current_profile.data.get("advanced_edition", false)
@onready var area_2d: Area2D = $"../Area2D"


func _ready() -> void:
	var _a = modulate.a
	modulate = Color.WHITE
	modulate.a = _a
	if inverted:
		_tweak = !_tweak
	if !_tweak:
		area_2d.type = 1
		hide()
		queue_free()
		return
	
