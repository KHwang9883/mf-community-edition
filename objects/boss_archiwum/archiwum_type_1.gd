extends "res://objects/boss_archiwum/archiwum.gd"

var counter_1: float = 50
var shooted: bool = false

var firestorm_sound = preload("res://objects/boss_archiwum/sounds/firestorm.wav")

var red_flame = preload("res://objects/boss_archiwum/projectiles/red_flame.tscn")

func _physics_process(_delta: float) -> void:
	super(_delta)
	
	if !movement_active || inactive: return
	
	var delta = Thunder.get_delta(_delta)
	var animated_sprite = get_node(sprite)
	
	counter_1 -= delta
	
	if !speed.x:
		speed.x = 200
	
	if counter_1 < 30 && !shooted:
		shooted = true
		animated_sprite.play("shooting")
		Audio.play_sound(firestorm_sound, self)
		await get_tree().create_timer(0.15, false).timeout
		if inactive: return
		
		NodeCreator.prepare_2d(red_flame, Scenes.current_scene).create_2d().call_method(func(flame: Area2D):
			flame.global_position = global_position
			if Thunder._current_player:
				flame.velocity = (12 - lives) * (1 if Thunder._current_player.global_position.x > global_position.x else -1)
			flame.get_node("AnimatedSprite2D").flip_h = flame.velocity < 0
			flame.flame_timing = 0.2 * lives
		)
		
		await get_tree().create_timer(0.15, false).timeout
		animated_sprite.play("default")
	
	if counter_1 < 0:
		shooted = false
		counter_1 = 70 + 10 * lives
		print(counter_1)


func activate() -> void:
	super()
	
	await get_tree().create_timer(5, false).timeout
	deactivate()


func deactivate() -> void:
	counter_1 = 50
	super()
