extends Path2D

func _ready() -> void:
	if KevinGlobal.activated:
		for i in get_children():
			if !i is PathFollow2D: continue
			i.speed = 80
