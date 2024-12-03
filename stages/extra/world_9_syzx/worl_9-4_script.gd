extends Node

@onready var sprite_2d_2: Sprite2D = $"../Parallax2D/Sprite2D2"


func _on_finish():
	var tw = sprite_2d_2.create_tween()
	tw.tween_property(sprite_2d_2, ^"position:y", -512, 1.0)
	
