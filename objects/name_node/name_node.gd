extends Node2D

@export var inverted: bool = false
@onready var _tweak: bool = Data.technical_values.get("clones_names", false)

func _ready() -> void:
	var _a = modulate.a
	modulate = Color.WHITE
	modulate.a = _a
	if inverted:
		_tweak = !_tweak
	if !_tweak:
		hide()
		queue_free()
