extends Node2D

const EXPLOSION_TANK = preload("res://stages/cutscenes/ending/part_1/scripts/explosion_tank.tscn")

var speed: Vector2

func _ready():
	
	var expl = EXPLOSION_TANK.instantiate()
	expl.position = global_position
	expl.reset_physics_interpolation()
	Scenes.current_scene.add_child(expl)


func _physics_process(delta):
	if speed == Vector2.ZERO: return
	speed.y += delta * 25
	position += speed * delta * 50
	rotation += delta * 12 * sign(speed.x)
	
	if position.y > 800: queue_free()
