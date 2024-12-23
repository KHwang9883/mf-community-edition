extends Area2D

func _ready() -> void:
	body_entered.connect(func(body: Node2D):
		body.queue_free.call_deferred()
	)
