extends Node2D

func _physics_process(delta: float) -> void:
	var value = floori(log(randi_range(1, 640)) / log(1 - 1/11)) + 1
	print (value)
