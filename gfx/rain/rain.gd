extends GPUParticles2D

@export_category("Rain")
@export var snap_to_camera: bool = true
@export var no_y_axis_snap: bool = false
@export_group("Sound", "sound_")
@export_range(-50, 50, 0.1, "or_less", "or_greater", "suffix:dB") var sound_basic_volume: float = -6
@export_range(-50, 50, 0.1, "or_less", "or_greater", "suffix:dB") var sound_dying_volume: float = -100.0
@export_range(0, 256, 0.1, "or_greater", "suffix:px") var sound_margin: float = 96.0
@export var sound_only_in_visible_rect: bool = true

var _prev_is_player_in_rect: bool = false
var _is_player_in_rect: bool = false
var _tweening: bool = false

@onready var particles: int = amount

@onready var _sound: AudioStreamPlayer = $Sound


func _ready() -> void:
	var cam: PlayerCamera2D = Thunder._current_camera
	if cam && snap_to_camera:
		physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
		cam.physics_interpolation_reset.connect(func() -> void:
			var screen_center: Vector2 = cam.get_screen_center_position() + Vector2(0, -240)
			var old_pos := global_position
			if no_y_axis_snap:
				global_position.x = screen_center.x
				old_pos.y = screen_center.y
			else:
				global_position = screen_center
			if old_pos.distance_squared_to(screen_center) > 480 ** 2:
				restart()
		)
	if !sound_only_in_visible_rect:
		_sound.volume_db = sound_basic_volume
	SettingsManager.settings_updated.connect(_update_visibility, CONNECT_DEFERRED)
	_update_visibility.call_deferred()


func _physics_process(delta: float) -> void:
	if !snap_to_camera:
		return
	var cam: PlayerCamera2D = Thunder._current_camera
	if !cam: return
	if no_y_axis_snap:
		global_position.x = cam.get_screen_center_position().x
	else:
		global_position = cam.get_screen_center_position() + Vector2(0, -240)


func _process(_delta: float) -> void:
	if !sound_only_in_visible_rect:
		return
	if _tweening: return
	
	var p: Player = Thunder._current_player
	if !p: return
	
	var rect := get_global_transform() * visibility_rect
	_is_player_in_rect = rect.has_point(p.global_position)
	
	if _prev_is_player_in_rect != _is_player_in_rect:
		_prev_is_player_in_rect = _is_player_in_rect
		_tweening = true
		
		var tw := create_tween().set_trans(Tween.TRANS_SINE)
		tw.tween_property(_sound, ^"volume_db", sound_basic_volume if _is_player_in_rect else sound_dying_volume, 2.0)
		await tw.finished
		
		_tweening = false

func _update_visibility() -> void:
	#match SettingsManager.QUALITY:
		#SettingsManager.QUALITY.MIN:
			#amount = mini(50, ceili(particles * 0.5))
		#
		#SettingsManager.QUALITY.MID:
			#amount = mini(200, ceili(particles * 0.8))
		#
		#SettingsManager.QUALITY.MAX:
			#amount = particles
	_sound.playing = is_visible_in_tree()
	_sound.stream_paused = get_tree().paused && is_visible_in_tree()
