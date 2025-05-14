extends PlayerCamera2D

@export var ignore_retro_scroll: bool = false
@export_enum("Left: -1", "Right: 1", "Up: 2", "Down: 3") var retro_scroll_direction: int = 1

@onready var _retro_tweak: bool = SettingsManager.get_tweak("retro_scroll", false)
@onready var _left_bd_init: bool = enable_left_border_death
@onready var _right_bd_init: bool = enable_right_border_death

var _tw: Tween

func _ready():
	super()


func _physics_process(delta: float) -> void:
	super(delta)
	
	if _retro_tweak:
		_xscroll = clampf(
			_xscroll,
			-1.25 if retro_scroll_direction != 1 else 0.0,
			1.25 if retro_scroll_direction != -1 else 0.0
		)


func switch_to_direction(dir: int) -> void:
	retro_scroll_direction = dir


func toggle_retro_scroll(to: bool) -> void:
	ignore_retro_scroll = to


func teleport(sync_position_only = false, reset_interpolation: bool = false) -> void:
	player = Thunder._current_player
	if !par is PathFollow2D && player:
		var _prev_pos: Vector2 = global_position
		global_position = Vector2(Thunder._current_player.global_position)
		if is_retro_scroll():
			var scr_dir: int = retro_scroll_direction
			if _prev_pos.x > limit_right - 320 && scr_dir == 1:
				_prev_pos.x = limit_right - 320
			elif _prev_pos.x < limit_left + 320 && scr_dir == -1:
				_prev_pos.x = limit_left + 320
			elif _prev_pos.y > limit_top - 240 && scr_dir == 3:
				_prev_pos.y = limit_top - 240
			elif _prev_pos.y < limit_top + 240 && scr_dir == 2:
				_prev_pos.y = limit_top + 240
			
			if (
				(global_position.x < _prev_pos.x && scr_dir == 1) || # Right
				(global_position.x > _prev_pos.x && scr_dir == -1)   # Left
			):
				global_position.x = _prev_pos.x
			
			if (
				(global_position.y < _prev_pos.y && scr_dir == 3) || # Down
				(global_position.y > _prev_pos.y && scr_dir == 2)    # Up
			):
				global_position.y = _prev_pos.y
			
		if reset_interpolation:
			reset_physics_interpolation()
			_xscroll = 0
	
	if sync_position_only: return
	
	if par is PathFollow2D:
		_screen_border_logic()
		_left_bd_init = enable_left_border_death
		_right_bd_init = enable_right_border_death
	elif is_retro_scroll():
		enable_left_border_death = false
		enable_right_border_death = false
		_screen_border_logic()
	
	_xscroll_logic()
	
	Thunder.view.cam_border.call_deferred()


func is_retro_scroll() -> bool:
	if !_retro_tweak || ignore_retro_scroll || !is_instance_valid(player): return false
	if player.completed || player.warp == player.Warp.OUT: return false
	
	return true


func set_camera_offset_smooth(to: Vector2, duration: float = 1.0) -> void:
	if SettingsManager.settings.xscroll:
		to = Vector2.ZERO
	if _tw: _tw.kill()
	_tw = create_tween().set_trans(Tween.TRANS_CUBIC)
	_tw.tween_property(self, "offset", to, duration).set_ease(Tween.EASE_IN_OUT)
