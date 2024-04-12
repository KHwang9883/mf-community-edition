extends "res://engine/objects/core/checkpoint/checkpoint.gd"

@onready var path_2d = $"../Path2D"
@onready var path_2d_2 = $"../Path2D2"

func _ready() -> void:
	super()
	if Data.values.checkpoint == id:
		path_2d.queue_free()
	else:
		path_2d_2.queue_free()
