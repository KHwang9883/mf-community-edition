extends Node2D

const PODOBOO = preload("res://engine/objects/enemies/podoboo/podoboo.tscn")
const SHOOT = preload("res://engine/objects/projectiles/sounds/shoot.wav")
const BOWSER_FLAME = preload("res://engine/objects/bosses/bowser/sounds/bowser_flame.wav")

@onready var lava_top_hud = $"../HUD/LavaTopHUD"
@onready var lava_hud = $"../HUD/LavaHUD"
#@onready var lava_hud_animation: AnimationPlayer = $"../HUD/LavaHUD/Animation"
#@onready var timer: Timer = $Timer # Timer
@onready var static_body_2d = $"../ParallaxBackground/ParallaxLayer/StaticBody2D"
@onready var sound: AudioStreamPlayer2D = $SoundRising
@onready var lava_bowser: Node2D = $LavaBowser
@onready var lava_top: Node2D = $LavaTop
@onready var light_effect_lava: Node2D = $LightEffectLava
@onready var marker_2d: Marker2D = $Marker2D
@onready var podoboos: Node2D = $"../Podoboos"
@onready var podoboos_mark: Marker2D = $"../Podoboos/Marker2D"
@onready var podoboos_arr: Array

var lava_arr_top: Array[Node2D]
var lava_arr_bottom: Array[Node2D]

var rising_step: int
var stopped_rising: bool
var lava_speed: float
var player: Player

var s_timer: float
var s_freq: float
var slowdown_tw: Tween
var next_podoboo: int

func _ready():
	player = Thunder._current_player
	podoboos_arr = podoboos.get_children()
	
	var lava_base = lava_bowser.get_child(0)
	lava_arr_bottom.resize(22)
	lava_arr_bottom[0] = lava_base
	for i in 21:
		var more_lava = lava_base.duplicate()
		more_lava.position.x = 32 * (i + 1)
		lava_bowser.add_child(more_lava)
		lava_arr_bottom[i + 1] = more_lava
		
		if i % 3 == 0:
			var more_light = light_effect_lava.duplicate()
			more_lava.add_child(more_light)
	
	var lava_base_top = lava_top.get_child(0)
	lava_arr_top.resize(22)
	lava_arr_top[0] = lava_base_top
	for i in 21:
		var more_lava = lava_base_top.duplicate()
		more_lava.position.x = -32 * (i + 1)
		lava_top.add_child(more_lava)
		lava_arr_top[i + 1] = more_lava
		
		if i % 3 == 0:
			var more_light = light_effect_lava.duplicate()
			more_lava.add_child(more_light)
	
	light_effect_lava.queue_free()
	
	var tw = create_tween()
	tw.tween_property(self, "s_freq", 96, 4.0)
	tw.tween_property(self, "lava_speed", -50, 0.5)
	#timer.timeout.connect(func():
		#_start_rising()
	#)

func _physics_process(delta):
	if is_instance_valid(player): 
		if player.completed && is_instance_valid(static_body_2d):
			static_body_2d.queue_free()
	
		if player.global_position.y < -8000 && !stopped_rising:
			stopped_rising = true
			hide()
			global_position.y = 0
			reset_physics_interpolation()
		
		match rising_step:
			0 when marker_2d.global_position.y < -1664:
				rising_step = 1
				slowdown_tw = create_tween()
				print("Rising step 0")
				slowdown_tw.tween_property(self, "lava_speed", -20, 2.0)
				slowdown_tw.tween_callback(print.bind("Rising back."))
				slowdown_tw.tween_property(self, "lava_speed", -50, 3.0)
				slowdown_tw.tween_callback(print.bind("Rising complete"))
				#_accelerate()
			1 when marker_2d.global_position.y < podoboos_mark.global_position.y:
				rising_step = 2
				next_podoboo = 1
				Audio.play_1d_sound(BOWSER_FLAME, false)
				var tw = create_tween().set_loops()
				tw.tween_property($PointLight2D, "energy", 2.4, 0.5)
				tw.tween_property($PointLight2D, "energy", 1.2, 0.5)
				var tw2 = create_tween().set_loops()
				tw2.tween_property($PointLight2D2, "energy", 2.4, 0.5)
				tw2.tween_property($PointLight2D2, "energy", 1.2, 0.5)
			2 when marker_2d.global_position.y < podoboos_arr[next_podoboo].global_position.y:
				var _marker: Vector2 = podoboos_arr[next_podoboo].global_position
				next_podoboo += 1
				var _podo = PODOBOO.instantiate()
				_podo.one_shot = true
				var _tindex: int = round( (_marker.x - 16) / 32.0 )
				var podo_y = lava_arr_bottom[_tindex].global_position.y
				_podo.position = Vector2(_marker.x, podo_y)
				_podo.jumping_height = 232
				_podo.interval = 0
				_podo.jumping = true
				_podo._on_jump()
				_podo.reset_physics_interpolation()
				Scenes.current_scene.add_child(_podo)
				Audio.play_sound(SHOOT, _podo, false)
				
			#1 when player.global_position.y < -4544:
				#rising_step = 2
				#_accelerate()
			#2 when player.global_position.y < -5952:
				#rising_step = 3
				#_accelerate()
			#3 when player.global_position.y < -6944:
				#rising_step = 4
				#_accelerate()
		s_timer += delta
		_lava_loop()
	
	global_position.y += lava_speed * delta
	
	if is_instance_valid(player):
		lava_hud.position.y = lava_top_hud.position.y + (global_position.y - player.global_position.y) / 20
		
		#var cam := get_viewport().get_camera_2d()
		#if is_instance_valid(cam):
			#if player.is_on_floor() && !is_equal_approx(cam.offset.y, 8) && player.global_position.y < 0 && player.global_position.y > -7360:
				#cam.offset.y = move_toward(cam.offset.y, 8, 5 * delta)
			#elif !is_zero_approx(cam.offset.y):
				#cam.offset.y = move_toward(cam.offset.y, 0, 50 * delta)


func _lava_loop() -> void:
	for i in len(lava_arr_top):
		lava_arr_top[i].position.y = sin(s_timer + (i * 0.25)) * s_freq
	for i in len(lava_arr_bottom):
		lava_arr_bottom[i].position.y = sin(s_timer + (i * 0.25) + PI) * s_freq


func _accelerate() -> void:
	create_tween().tween_property(self, "lava_speed", lava_speed - 37.5, 1)


func koniec_gry() -> void:
	lava_hud.material = null
	if slowdown_tw && slowdown_tw.is_valid():
		slowdown_tw.kill()
	
	var tw = create_tween().set_parallel()
	tw.tween_property(self, "lava_speed", 0.0, 0.5)
	tw.tween_property(lava_hud, "modulate:a", 0, 2)
	tw.tween_property(lava_top_hud, "modulate:a", 0, 2)
