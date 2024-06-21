extends Node2D

@onready var sprite_2d = $Sprite2D

func _ready():
	var tw = create_tween()
	tw.tween_property(sprite_2d, "scale", Vector2.ZERO, 0.6)
	tw.tween_callback(queue_free)

func _physics_process(delta):
	position.y -= delta * 150
