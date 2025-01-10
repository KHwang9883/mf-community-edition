extends "res://engine/objects/enemies/spinies/spiny_egg.gd"

var vdir: Vector2

func _ready() -> void:
	await super()
	
	var pl = Thunder._current_player
	if !pl:
		vdir = Vector2.DOWN
		return
	vdir = global_position.direction_to(pl.global_position)
	jump(200)


func _physics_process(delta: float) -> void:
	super(delta)
	
	speed += 2500 * 0.3 * delta * vdir
	if abs(speed.x) > 1000:
		speed.x = 1000 * signf(speed.x)
	if abs(speed.y) > 1000:
		speed.y = 1000 * signf(speed.y)
