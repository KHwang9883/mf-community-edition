extends Area2D



func _on_body_entered(body: Node2D) -> void:
	#print(body)
	if body is GeneralMovementBody2D:
		body.queue_free()
		#print(body.name)
