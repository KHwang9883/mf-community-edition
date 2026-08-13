extends Area2D

@export var can_break_bricks: bool = true

func _ready() -> void:
	get_tree().create_timer(0.6, false, true).timeout.connect(func() -> void:
		queue_free()
	)


func _on_body_entered(body: Node2D) -> void:
	if !can_break_bricks: return
	if body.has_method(&"bricks_break"):
		body.bricks_break()
