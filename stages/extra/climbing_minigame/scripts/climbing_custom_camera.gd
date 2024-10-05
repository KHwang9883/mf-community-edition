extends PlayerCamera2D

var moving: bool = false
var can_get_faster: bool = false
var y_counter: float
var rand_offset: int = 60
var flower_counter: int = 10

var platform = preload("res://stages/extra/climbing_minigame/objects/platform_custom/platform_path_custom.tscn")
var skulltroopa = preload("res://stages/extra/climbing_minigame/objects/paratroopa_skull/paratroopa_green_skully.tscn")
var coins = preload("res://stages/extra/climbing_minigame/objects/coins/coins.tscn")
var flower = preload("res://stages/extra/climbing_minigame/objects/fire_flower/fire_flower_lava_run.tscn")
var podoboo = preload("res://engine/objects/enemies/podoboo/podoboo.tscn")
#var roto = preload("res://engine/objects/enemies/rotos/roto_center.tscn")
#var rotodisc = preload("res://engine/objects/enemies/rotos/roto_red.tscn")

@onready var platform_path: AnimatableBody2D = $"../../PlatformPath"
@onready var platform_path_2: AnimatableBody2D = $"../../PlatformPath2"
@onready var platform_path_3: AnimatableBody2D = $"../../PlatformPath3"
@onready var platform_path_4: AnimatableBody2D = $"../../PlatformPath4"
@onready var jumping_cheeps_generator: Node = $"../../JumpingCheepsGenerator"

@onready var mariomarker: Sprite2D = $"../../HUD/Mariomarker"
@onready var mariomarker_init_pos: float = mariomarker.global_position.y

@onready var moving_group: Node2D = $".."

var ohno_sound = preload("res://music/climbing_minigame/mario_ohno.wav")

var bg_sounds = []

func _ready() -> void:
	super()
	
	get_tree().create_timer(20, false).timeout.connect(func():
		podo_create()
	)
	
	#get_tree().create_timer(40, false).timeout.connect(func():
		#roto_create()
	#)
	
	#get_tree().create_timer(80, false).timeout.connect(func():
		#podo_create_advanced_sequence()
	#)
	
	y_counter = moving_group.global_position.y
	
	Audio.play_1d_sound(ohno_sound)
	
	setup_platform(platform_path, randf_range(128, 568))
	setup_platform(platform_path_2, randf_range(128, 568))
	setup_platform(platform_path_3, randf_range(128, 528))
	setup_platform(platform_path_4, randf_range(128, 568))
	
	Data.values['highest'] = Data.values['miles'] if 'miles' in Data.values else 0
	Data.values['miles'] = 0
	
	await Scenes.current_scene.stage_ready
	await get_tree().create_timer(7.67, false, false, true).timeout
	moving = true
	
	await get_tree().create_timer(1.0, false, false, false).timeout
	can_get_faster = true
	
	await get_tree().create_timer(2.0, false, false, false).timeout
	jumping_cheeps_generator.enabled = true


func setup_platform(platf: AnimatableBody2D, pos: float) -> void:
	platf.collision_layer = 0
	platf.position.x = pos
	platf.reset_physics_interpolation()


func teleport(sync_position_only = false, reset_interpolation: bool = false) -> void:
	player = Thunder._current_player
	
	if player:
		global_position.x = int(Thunder._current_player.global_position.x)
		if reset_interpolation:
			reset_physics_interpolation()
	
	Thunder.view.cam_border.call_deferred()


func _physics_process(_delta: float) -> void:
	super(_delta)
	
	player = Thunder._current_player
	if player && player.is_on_floor():
		platform_path.collision_layer = 112
		platform_path_2.collision_layer = 112
		platform_path_3.collision_layer = 112
		platform_path_4.collision_layer = 112
	
	var delta = Thunder.get_delta(_delta)
	
	if abs(moving_group.global_position.y - y_counter) > rand_offset:
		create_platform()
	
	if moving && player:
		moving_group.global_position.y -= 1 * delta
		
		if player.global_position.y < moving_group.global_position.y + 112 && can_get_faster:
			moving_group.global_position.y -= 2 * delta
		if player.global_position.y < moving_group.global_position.y - 16:
			moving_group.global_position.y -= 3 * delta
	
	mariomarker.position.y = mariomarker_init_pos + (moving_group.global_position.y / 8)
	if mariomarker.global_position.y < 96:
		print("Change")
	
	Data.values['miles'] = int(abs(moving_group.global_position.y))
	
	if Data.values['highest'] < Data.values['miles']:
		Data.values['highest'] = Data.values['miles']


func create_platform() -> void:
	# platform spawn
	var plati = platform.instantiate()
	plati.global_position = moving_group.global_position + Vector2(randi_range(200, 440), -50)
	Scenes.current_scene.add_child(plati)
	
	rand_offset = randi_range(100, 180)
	y_counter = moving_group.global_position.y
	
	var left_right = randi_range(0, 1)
	
	# skull paratroopa spawn
	var skulli = skulltroopa.instantiate()
	skulli.global_position = Vector2(-32 if left_right else (640 + 32), randi_range(32, 400))
	skulli.velocity = Vector2(1.2, 0) if left_right else Vector2(-1.2, 0)
	moving_group.add_child(skulli)
	
	# coins
	if randi_range(0, 4) == 3:
		var coinsi = coins.instantiate()
		coinsi.global_position = plati.global_position - Vector2(0, 28)
		Scenes.current_scene.add_child(coinsi)
	
	# flower spawn
	flower_counter -= 1
	
	if flower_counter <= 0:
		var floweri = flower.instantiate()
		floweri.global_position = plati.global_position - Vector2(0, 16)
		floweri.appear_distance = 0
		floweri.force_powerup_state = true
		Scenes.current_scene.add_child(floweri)
		flower_counter = 10


#func play_bg_sound() -> void:
	#get_tree().create_timer(4, false).timeout.connect(play_bg_sound)
	#
	#var i = randi_range(0, len(bg_sounds) - 1)
	#
	#for g in range(4):
		#Audio.play_1d_sound(
			#bg_sounds[i]
		#)


func podo_create() -> void:
	get_tree().create_timer(6, false).timeout.connect(podo_create)
	
	var podo1 = podoboo.instantiate()
	podo1.position = Vector2(128, 448-16)
	moving_group.add_child(podo1)
	
	var podo2 = podoboo.instantiate()
	podo2.position = Vector2(512, 448-16)
	moving_group.add_child(podo2)


#func podo_create_advanced_sequence() -> void:
	#get_tree().create_timer(30, false).timeout.connect(podo_create_advanced_sequence)
	#
	#Audio.play_1d_sound(alarm)
	#await get_tree().create_timer(4, false).timeout
	#
	#for i in range(30):
		#podo_create_advanced(i)


#func podo_create_advanced(i: int) -> void:
	#await get_tree().create_timer(float(i) / 4.0, false).timeout
	#Audio.play_1d_sound(woo)
	#var podo1 = podoboo.instantiate()
	#podo1.interval = 0
	#podo1.position = Vector2(320, 448-16)
	#podo1.speed.x = randi_range(-200, 200)
	#podo1.jumping_height = 400
	#podo1._on_jump()
	#podo1.get_node("Interval").queue_free()
	#moving_group.add_child(podo1)


#func roto_create() -> void:
	#get_tree().create_timer(randi_range(4, 7), false).timeout.connect(roto_create)
	#
	#var rotoi = roto.instantiate()
	#rotoi.position = Vector2(randi_range(0, 640), -256 + moving_group.global_position.y)
	#
	#var rotodisci = rotodisc.instantiate()
	#rotodisci.frequency = randi_range(-100, 100)
	#rotodisci.amplitude_changing_speed = randi_range(100, 500)
	#rotodisci.amplitude_enable = !randi_range(0, 1)
	#rotoi.add_child(rotodisci)
	#
	#Scenes.current_scene.add_child(rotoi)
