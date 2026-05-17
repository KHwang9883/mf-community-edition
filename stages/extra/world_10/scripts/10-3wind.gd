extends Node

@export_custom(PROPERTY_HINT_NONE, "suffix:px/s") var wind_speed: float = 0
@export_range(0, 1, 0.001, "or_greater", "suffix:x") var snow_recovery_accumulation_rate: float = 0.005
@export_range(0, 1, 0.001, "or_greater", "suffix:x") var snow_recovery_decumulation_each_jump: float = 0.1

const SNOW_BREAK = preload("res://stages/extra/world_10/sfx/snow_break.wav")
const PLAYER_PHYSICS: Array[StringName] = [
	&"walk_max_walking_speed",
	&"walk_max_running_speed",
	&"jump_speed",
]
const PARTICLE_VELOCITY_ROTATIONS: PackedFloat32Array = [PI/6, PI/3, 2*PI/3, 5*PI/6]

var snow_cover_accumulation: float = 0:
	set(value):
		snow_cover_accumulation = clampf(value, 0, 1)
		if _par:
			_snow_cover_accumulation_changed()
		if _snow_cover:
			_snow_cover.region_rect = Rect2(
				32, 192,
				32, remap(snow_cover_accumulation, 0, 1, 0, 32)
			)
			_snow_cover.offset.y = remap(snow_cover_accumulation, 0, 1, 16, 0)
			_snow_cover.modulate.a = snow_cover_accumulation
var jumped: bool = false

@onready var _par: Player = get_parent()
@onready var _snow_cover: Sprite2D = $"../SnowCover"
@onready var _snow_particle: GPUParticles2D = $"../../SnowParticle"


func _ready() -> void:
	snow_cover_accumulation = 0
	SettingsManager.settings_updated.connect(func() -> void:
		_snow_particle.visible = SettingsManager.get_quality() > SettingsManager.QUALITY.MIN
	)

func _physics_process(delta: float) -> void:
	if !_par || _par.warp != Player.Warp.NONE:
		return
	if _par.completed:
		snow_cover_accumulation = move_toward(snow_cover_accumulation, 0, 0.2 * delta)
	
	if !is_zero_approx(wind_speed):
		var mv := Vector2.RIGHT * wind_speed * delta
		var kc := KinematicCollision2D.new()
		var col := _par.test_move(_par.global_transform, mv, kc)
		if col && kc:
			mv = mv.slide(kc.get_normal())
		
		if !_par.no_movement && !_par.completed:
			_par.move_and_collide(mv)
		
		var acc := absf(wind_speed * snow_recovery_accumulation_rate)
		if _par.is_crouching:
			acc *= 0.5
		snow_cover_accumulation = move_toward(snow_cover_accumulation, 1, 0.0 if !_par.is_on_floor() else acc * delta)
	
	_snow_particle.global_position = _par.global_position
	
	if jumped && _par.is_on_floor():
		jumped = false
	if _par.jumped && !jumped && snow_cover_accumulation > 0:
		jumped = true
		snow_cover_accumulation = clamp(snow_cover_accumulation - snow_recovery_decumulation_each_jump, 0, 1)
		if _snow_particle.visible && snow_cover_accumulation > 0.1:
			Audio.play_1d_sound(SNOW_BREAK)
			for i in 4:
				_snow_particle.emit_particle(_snow_particle.global_transform, Vector2.RIGHT.rotated(-PARTICLE_VELOCITY_ROTATIONS[i]) * randf_range(50, 200), Color.WHITE, Color.WHITE, GPUParticles2D.EMIT_FLAG_POSITION | GPUParticles2D.EMIT_FLAG_VELOCITY)
	_par.set_meta(&"not_slidable", snow_cover_accumulation > 0.2)

	for i in PLAYER_PHYSICS:
		if !_par.config_buffer || (!i in _par.config_buffer):
			continue
		_par.suit.physics_config[i] = _par.config_buffer[i] *  clampf(1 - snow_cover_accumulation, 0.0 if i != &"jump_speed" else 0.1, 1.0)

func _snow_cover_accumulation_changed() -> void:
	pass
