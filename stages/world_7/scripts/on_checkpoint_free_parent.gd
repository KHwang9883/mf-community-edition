extends Node

func _ready() -> void:
	if Data.values.checkpoint != -1:
		get_parent().queue_free()
