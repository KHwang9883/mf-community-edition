extends Area2D


func _ready() -> void:
	body_entered.connect(func(body: Node2D):
		var tween = create_tween()
		tween.tween_property($CollisionShape2D/Sprite2D, "modulate:a", 0.0, 0.7)
	)
	
	body_exited.connect(func(body: Node2D):
		var tween = create_tween()
		tween.tween_property($CollisionShape2D/Sprite2D, "modulate:a", 1.0, 0.7)
	)
	
