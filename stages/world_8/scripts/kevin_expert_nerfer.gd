extends Node2D

@export var inverted: bool = false

func _ready() -> void:
	if KevinGlobal.activated && inverted:
		queue_free()
		return
	elif !KevinGlobal.activated && !inverted:
		queue_free()
	else:
		modulate = Color.WHITE
