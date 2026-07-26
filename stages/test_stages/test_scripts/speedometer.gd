extends Label

var counter: float
var y_count: float
var y_count2: float

func _physics_process(delta: float) -> void:
	var pl = Thunder._current_player
	if !pl: return
	if pl.speed.x > 0 && pl.global_position.x < 640.1:
		counter += delta
	if !pl.is_on_floor():
		y_count += delta
		if pl.speed.y < 0:
			y_count2 += delta
	text = str(counter) + "\n" + str(y_count) + "\n" + str(y_count2)
	
	if Input.is_key_pressed(KEY_SPACE):
		counter = 0
		y_count = 0
		y_count2 = 0
