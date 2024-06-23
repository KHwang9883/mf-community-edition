extends "res://engine/objects/core/checkpoint/checkpoint.gd"

@onready var path_follow_2d = $"../Path2D6/PathFollow2D"

func _ready():
	super()
	
	if Data.values.checkpoint == id:
		path_follow_2d.progress = 5484
