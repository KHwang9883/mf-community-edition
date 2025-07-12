extends "res://objects/boss_archiwum/archiwum.gd"

var counter_2: float = 0
var shooted: bool = true

var magma_sound = preload("res://objects/boss_archiwum/sounds/magmabazooka.wav")

var fly_flame = preload("res://objects/boss_archiwum/projectiles/fly_flame.tscn")

func _physics_process(_delta: float) -> void:
	super(_delta)
	
	if !movement_active || inactive: return
	
	var delta = Thunder.get_delta(_delta)
	var animated_sprite = get_node(sprite)
	
	counter_2 -= delta
	
	if is_on_floor():
		speed.x = 0
	
	if speed.y >= -10 && !shooted:
		shooted = true
		if !is_instance_valid(Thunder._current_player): return
		
		animated_sprite.play("shooting")
		
		await get_tree().create_timer(0.15, false).timeout
		Audio.play_sound(magma_sound, self)
		
		for i in range(3):
			NodeCreator.prepare_2d(fly_flame, Scenes.current_scene).create_2d().call_method(func(flame: Area2D):
				flame.global_position = global_position
				flame.rotation_degrees = -45 + (45 * i) + (0 if Thunder._current_player.global_position.x > global_position.x else 180)
				flame.velocity = 12
			)
	
	if counter_2 < 0 && is_on_floor():
		if !is_instance_valid(Thunder._current_player): return
		shooted = false
		speed.x = 120 / (float(lives) / 2.0) * (1 if Thunder._current_player.global_position.x > global_position.x else -1)
		speed.y = rng.randi_range(-400, -600)
		counter_2 = 120 * (float(lives) / 5.0)

func activate() -> void:
	super()
	
	await get_tree().create_timer(8, false).timeout
	deactivate()


func deactivate() -> void:
	counter_2 = 20
	speed.x = 0
	shooted = true
	super()
