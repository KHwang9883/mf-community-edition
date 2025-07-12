@tool
extends "res://engine/objects/enemies/rotos/roto_red.gd"

@export_range(0, 180, 0.01, "degrees") var next_phase_step: float = 90
@export_range(0, 20, 0.01, "suffix:s") var await_interval: float = 0.25

var _tw: Tween

@onready var prev_phase: float = phase
@onready var next_phase: float = _get_next_phase()


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()
		if !preview:
			if _tw:
				_tw.stop()
				_tw.kill()
				_tw = null
				
				await get_tree().process_frame
				
				prev_phase = phase
				next_phase = _get_next_phase()
			return
	
	oval_pos()
	
	if amplitude_changing_speed > 0 && amplitude_enable:
		if _amplitude_in:
			amplitude = amplitude.move_toward(amplitude_min, amplitude_changing_speed * delta)
			_amplitude_in = !(amplitude == amplitude_min)
		else:
			amplitude = amplitude.move_toward(amplitude_max, amplitude_changing_speed * delta)
			_amplitude_in = (amplitude == amplitude_max)
	
	if !_tw:
		_tw = create_tween().set_trans(Tween.TRANS_SINE)
		_tw.tween_property(self, ^"phase", next_phase, absf(next_phase - prev_phase) / absf(frequency))
		_tw.tween_callback(func() -> void:
			if is_zero_approx(fmod(phase, 360)):
				phase = 0
				prev_phase = phase
				next_phase = 0
			
			phase = next_phase
			prev_phase = phase
			next_phase = _get_next_phase()
		)
		_tw.tween_interval(await_interval)
		_tw.tween_callback(func() -> void: _tw = null)
	
	track_rot = wrapf(track_rot + track_rot_speed * delta, -180, 180)

func oval_pos() -> void:
	position = Thunder.Math.oval(Vector2.ZERO, amplitude, deg_to_rad(phase), deg_to_rad(track_rot)).round()


func _get_next_phase() -> float:
	return phase + next_phase_step * signf(frequency)
