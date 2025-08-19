extends Node

const THROW = preload("res://engine/objects/projectiles/sounds/throw.wav")
@onready var toad: AnimatedSprite2D = $"../toad"

@onready var player: Player = Thunder._current_player

@onready var castle_end_marker = $"../CastleEndMarker"
@onready var camera_2d: Camera2D = $"../Camera2D"
@onready var destruction: AudioStreamPlayer = $"../Destruction"
@onready var house_2: Sprite2D = $"../House-2"
@onready var tanks: Area2D = $"../Tanks"

@onready var fire_flower: Powerup = %FireFlowerForced
@onready var life_mushroom: CharacterBody2D = %LifeMushroom
@onready var atom_replenisher: CharacterBody2D = %AtomReplenisher

var _player_speed: float = 250
var _moving: bool = false
var _finished: float = 0.0
var toad_moving: bool = false


signal items_spawned
signal items_collected

func _ready() -> void:
	await get_parent().ready
	player = Thunder._current_player
	player.completed = true
	_moving = true
	
	await _time(1.5)
	#var tw = create_tween()
	#tw.tween_property(player, "modulate:a", 1.0, 1.0)
	#await _time(0.5)
	_moving = false
	
	await _time(1)

	var tw = create_tween().set_trans(Tween.TRANS_SINE)
	tw.tween_property(camera_2d, "position:x", 832, 1.5)
	
	await _time(1.8)
	toad.play(&"jump")
	_speak()
	Audio.play_sound(preload("res://engine/objects/players/prefabs/sounds/jump.wav"), toad, false)
	tw = create_tween().set_trans(Tween.TRANS_SINE)
	tw.tween_property(toad, "position:y", 393 - 32, 0.3).set_ease(Tween.EASE_OUT)
	tw.tween_property(toad, "position:y", 393, 0.3).set_ease(Tween.EASE_IN)
	tw.tween_callback(toad.play.bind(&"cursed"))
	tw.tween_interval(0.4)
	tw.tween_callback(toad.play.bind(&"walk"))
	tw.tween_callback(toad.set_flip_h.bind(true))
	tw.tween_property(toad, "position:x", 1022, 0.8)
	tw.tween_callback(toad.play.bind(&"default"))
	tw.tween_property(toad, "modulate:a", 0.0, 0.5)
	tw.tween_interval(0.6)
	tw.tween_callback(spawn_item)
	await items_spawned
	_moving = true
	
	await items_collected
	
	destruction.play()
	camera_2d.shock(100, Vector2(2, 2))
	await _time(1.0)
	tw = create_tween().set_trans(Tween.TRANS_SINE)
	tw.tween_callback(toad.play.bind(&"walk"))
	tw.tween_callback(toad.set_flip_h.bind(false))
	tw.tween_callback(func():
		toad_moving = true
		toad.speed_scale = 1.3
	)
	tw.tween_property(toad, "modulate:a", 1.0, 0.5)
	await tw.finished
	player.direction = -1
	_player_speed = 0
	_moving = true
	await _time(0.8)
	destroying = true
	#tw = create_tween().set_trans(Tween.TRANS_SINE)
	#tw.tween_property(camera_2d, "position:x", 640, 1.0)
	
	await _time(7.0)
	_finished = 3

var fire_flower_rotating: bool
var life_rotating: bool
var atom_rotating: bool
func spawn_item() -> void:
	var pl = Thunder._current_player
	if !pl: return
	var tw: Tween
	if pl.suit.type != Data.PLAYER_POWER.FULL:
		Audio.play_1d_sound(THROW)
		fire_flower.global_position = toad.global_position
		fire_flower.modulate.a = 0.05
		tw = fire_flower.create_tween()
		tw.tween_property(fire_flower, "modulate:a", 1.0, 0.3)
		fire_flower.reset_physics_interpolation()
		fire_flower.speed = Vector2(-350, -280)
		fire_flower_rotating = true
		Thunder._connect(fire_flower.collided_floor, func():
			fire_flower.speed.x = 0
			fire_flower_rotating = false
			fire_flower.get_node("Sprite").rotation = 0
		)
		await _time(0.5)
	Audio.play_1d_sound(THROW)
	life_mushroom.global_position = toad.global_position
	life_mushroom.modulate.a = 0.05
	tw = life_mushroom.create_tween()
	tw.tween_property(life_mushroom, "modulate:a", 1.0, 0.3)
	life_mushroom.reset_physics_interpolation()
	life_mushroom.speed = Vector2(-300, -280)
	life_rotating = true
	Thunder._connect(life_mushroom.collided_floor, func():
		life_mushroom.speed.x = 0
		life_rotating = false
		life_mushroom.get_node("Sprite").rotation = 0
	)
	
	

	if !Data.technical_values.custom_saved_values.get("item_replenisher"):
		await _time(0.5)
		Audio.play_1d_sound(THROW)
		atom_replenisher.global_position = toad.global_position
		atom_replenisher.modulate.a = 0.05
		tw = atom_replenisher.create_tween()
		tw.tween_property(atom_replenisher, "modulate:a", 1.0, 0.3)
		atom_replenisher.reset_physics_interpolation()
		atom_replenisher.speed = Vector2(-250, -280)
		atom_rotating = true
		Thunder._connect(atom_replenisher.collided_floor, func():
			atom_replenisher.speed.x = 0
			atom_rotating = false
			atom_replenisher.get_node("Sprite").rotation = 0
		)
	
	items_spawned.emit()


var toad_speed: float
var destroying: bool
var c: float
func _physics_process(delta: float) -> void:
	if _moving:
		player.speed.x = _player_speed
		_player_speed = move_toward(_player_speed, 175 * (-1.25 if toad_moving else 1.0), delta * 250)
		if player.position.x > 720 && !toad_moving:
			_moving = false
			items_collected.emit()
	
	if toad_moving:
		toad_speed = min(350, toad_speed + 125 * delta)
		toad.position.x -= toad_speed * delta
	
	if fire_flower_rotating:
		fire_flower.get_node("Sprite").rotation_degrees += 15 * delta * 50
	
	if life_rotating:
		life_mushroom.get_node("Sprite").rotation_degrees += 15 * delta * 50
	
	if atom_rotating:
		atom_replenisher.get_node("Sprite").rotation_degrees += 15 * delta * 50
	
	if destroying:
		house_2.offset.x = randi_range(-2, 2)
		tanks.position.x -= 100 * delta
	
	if tanks.global_position.x < -192:
		house_2.position.y += 30 * delta
		
		c -= delta * 20
		if c < 0 && house_2.global_position.y < 480:
			c = 1
			var ex = preload("res://stages/cutscenes/starting/scripts/explosion_house.tscn").instantiate()
			ex.position = Vector2(house_2.global_position.x, 416)
			Scenes.current_scene.add_child(ex)
	
	if _finished > 2.0 && _finished < 999:
		_finished = 1000
		Scenes.current_scene.end()



func _time(sec: float) -> void:
	await get_tree().create_timer(sec, false).timeout

func _speak() -> void:
	var text = preload("res://stages/cutscenes/ending/part_2/objects/mario_text/mario_text.tscn").instantiate()
	text.global_position = toad.global_position - Vector2(0, 64)
	Scenes.current_scene.add_child(text)
