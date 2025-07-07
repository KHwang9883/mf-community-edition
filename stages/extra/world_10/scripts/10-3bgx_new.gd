extends Node

var stage := -1:
	set = update_stage

var wind_speed_toward: int = 0
var pitch_scale_toward: float = 1
var scrolling_speed_toward: float = 1
var wind_sound_db_toward: float = -25
var snowstorm_opacity_toward: float = 0.25

@onready var scrolling: AnimationPlayer = $"../Scrolling"
@onready var wind_and_snow_cover: Node = $"../Mario/WindAndSnowCover"
@onready var snow: GPUParticles2D = $"../FGs/Snowing/Snow"
@onready var wind_sound: AudioStreamPlayer = $"../FGs/Snowstorm/WindSound"
@onready var snowstorm: Parallax2D = $"../FGs/Snowstorm"
@onready var snowstorm_2: Parallax2D = $"../FGs/Snowstorm2"

@onready var player = Thunder._current_player

var _stage_switch: int = -1
var _first_done = false
var _checkpoint_done = false
var _second_done = false
var _third_done = false


func _ready() -> void:
	_stage_switch = 0


func _physics_process(delta: float) -> void:
	check_player()
	
	if stage != _stage_switch:
		stage = _stage_switch
	
	update_values(delta)


func update_stage(val: int) -> void:
	stage = val
	
	if val == 0:
		wind_speed_toward = 0
		pitch_scale_toward = 1
		scrolling_speed_toward = 1
		wind_sound_db_toward = -25
		snowstorm_opacity_toward = 0.25
		snow.process_material.gravity = Vector3.ZERO
		snow.amount_ratio = 0.2
		snow.process_material.initial_velocity = Vector2(50, 100)
		print('bgx stage 0')
	
	if val == 1:
		wind_speed_toward = -50
		pitch_scale_toward = 1
		scrolling_speed_toward = 5
		wind_sound_db_toward = 0
		snowstorm_opacity_toward = 0.5
		snow.process_material.gravity = Vector3(-150, 50, 0)
		snow.amount_ratio = 0.5
		snow.process_material.initial_velocity = Vector2(100, 200)
		print('bgx stage 1')
	
	if val == 2:
		wind_speed_toward = -100
		pitch_scale_toward = 1.5
		scrolling_speed_toward = 8.5
		wind_sound_db_toward = 5
		snowstorm_opacity_toward = 0.7
		snow.process_material.gravity = Vector3(-500, 100, 0)
		snow.amount_ratio = 1
		snow.process_material.initial_velocity = Vector2(150, 300)
		print('bgx stage 2')


func check_player() -> void:
	if !is_instance_valid(player):
		return
	
	if player.global_position.x > 1728 && !_first_done:
		_stage_switch = 1
	
	if player.global_position.x > 4992 && !_first_done:
		_stage_switch = 2
		_first_done = true
	
	if player.global_position.x > 9024 && !_checkpoint_done:
		_stage_switch = 1
		_checkpoint_done = true
		
	if player.global_position.x > 10880 && !_second_done:
		_stage_switch = 2
		_second_done = true
	
	if player.global_position.x > 17856 && !_third_done:
		_stage_switch = 1
	
	if player.global_position.x > 18432 && !_third_done:
		_stage_switch = 0
		_third_done = true


func update_values(delta: float) -> void:
	scrolling.speed_scale = move_toward(scrolling.speed_scale, scrolling_speed_toward, delta * 0.8)
	if is_instance_valid(wind_and_snow_cover):
		wind_and_snow_cover.wind_speed = move_toward(wind_and_snow_cover.wind_speed, wind_speed_toward, delta * 5)
	wind_sound.pitch_scale = move_toward(wind_sound.pitch_scale, pitch_scale_toward, delta * 0.6)
	wind_sound.volume_db = move_toward(wind_sound.volume_db, wind_sound_db_toward, delta * 5)
	snowstorm.modulate.a = move_toward(snowstorm.modulate.a, snowstorm_opacity_toward, delta * 0.5)
	snowstorm_2.modulate.a = move_toward(snowstorm.modulate.a, snowstorm_opacity_toward, delta * 0.5)
