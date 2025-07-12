extends "res://objects/boss_archiwum/archiwum.gd"

var counter_2: float = 0
var shoot_c: float = 60
var phase: bool = false

var magma_sound = preload("res://objects/boss_archiwum/sounds/pharaoh1.wav")

var fly_flame = preload("res://objects/boss_archiwum/projectiles/ball.tscn")
var yellow_flame = preload("res://objects/boss_archiwum/projectiles/yellow_flame.tscn")

func _physics_process(_delta: float) -> void:
	super(_delta)
	
	if !movement_active || inactive: return
	
	var delta = Thunder.get_delta(_delta)
	var animated_sprite = get_node(sprite)
	
	counter_2 -= delta
	shoot_c -= delta
	
	if is_on_floor():
		speed.x = 0
	
	if !phase:
		if speed.y >= -10 && shoot_c <= 0:
			if !is_instance_valid(Thunder._current_player): return
			
			shoot_c = 160 * (float(lives) / 5.0)
			
			animated_sprite.play("shooting")
			
			Audio.play_sound(magma_sound, self)
			
			NodeCreator.prepare_2d(fly_flame, Scenes.current_scene).create_2d().call_method(func(flame: Area2D):
				flame.global_position = global_position
				flame.look_at(Thunder._current_player.global_position)
				flame.velocity = 12
			)
		
		if counter_2 < 0 && is_on_floor():
			if !is_instance_valid(Thunder._current_player): return
			speed.x = 120 / (float(lives) / 4.0) * (1 if Thunder._current_player.global_position.x > global_position.x else -1)
			speed.y = rng.randi_range(-400, -600)
			counter_2 = 160 * (float(lives) / 5.0)

func activate() -> void:
	super()
	
	await get_tree().create_timer(8, false).timeout
	deactivate()


func deactivate() -> void:
	counter_2 = 20
	shoot_c = 60
	speed.x = 0
	phase = false
	super()
