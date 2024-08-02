extends HBoxContainer

var timer: float = 0
var counters: float = 1000

func _process(delta: float) -> void:
	if counters < 0:
		timer += delta * 5
		counters -= delta * 5
	else:
		counters = 0
	position.x = counters * sin(timer)
