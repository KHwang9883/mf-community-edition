extends "res://engine/objects/fluid/lava_area.gd"

func _ready() -> void:
	# Body in/out of water
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
