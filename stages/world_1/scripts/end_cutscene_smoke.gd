extends Node2D

@onready var sprite_2d = $Sprite2D
var rotation_speed = 0
var y_modifier = 0

func _ready():
	var tw = create_tween()
	tw.tween_property(sprite_2d, "scale", Vector2.ZERO, 0.6)
	tw.tween_callback(queue_free)

func _physics_process(delta):
	position.y -= delta * (150 + y_modifier)
	
	rotation_degrees += rotation_speed * delta
