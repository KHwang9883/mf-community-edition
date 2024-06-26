extends Sprite2D

const EXPLOSION_TANK = preload("res://stages/cutscenes/ending/part_1/scripts/explosion_tank.tscn")

@export var speed: Vector2

var counter: float

func _physics_process(delta):
	speed.y += delta * 12
	position += speed * delta * 50
	rotation += delta * 7.5 * sign(speed.x)
	counter += delta
	if counter > 0.1 && Thunder.view.is_getting_closer(self, 32):
		counter = 0.0
		var explo = EXPLOSION_TANK.instantiate()
		Scenes.current_scene.add_child(explo)
		explo.global_position = global_position + randi_range(-32, 32) * Vector2.ONE
	if position.y > 700: modulate.a -= delta
	if modulate.a <= 0.0: queue_free()
