@tool
extends Area2D

const PHANTOMIC_BALL: PackedScene = preload("../phantomic_ball/phantomic_ball.tscn")

@export_category("Roto-Disk")
@export_group("Preview")
@export var preview: bool:
	set(to):
		preview = to
		if preview:
			_origin = position
			_amplitude = amplitude
			_phase = phase
			_track_rot = track_rot
			if amplitude_changing_speed > 0 && amplitude_enable:
				amplitude = amplitude_min
		else:
			position = _origin
			amplitude = _amplitude
			phase = _phase
			track_rot = _track_rot
			_amplitude_in = false
@export var circle_line_spot: int = 32
@export var line_color: Color = Color.ANTIQUE_WHITE
@export_group("Physics")
@export_subgroup("Amplitude")
@export var amplitude_enable: bool = false
@export var amplitude: Vector2 = 150 * Vector2.ONE:
	set(to):
		amplitude = to
		if Engine.is_editor_hint() && !preview:
			oval_pos()
@export_range(0, 9999, 0.01, "suffix:px/s") var amplitude_changing_speed: float = 350
@export var amplitude_min: Vector2
@export var amplitude_max: Vector2 = 200 * Vector2.ONE
@export_subgroup("Phase")
@export_range(-180, 180, 0.01, "suffix:°") var phase: float:
	set(to):
		phase = to
		if Engine.is_editor_hint() && !preview:
			oval_pos()
@export_range(-21599.94, 21599.94, 0.001, "suffix:°/s") var frequency: float = 100
@export_subgroup("Track rotation")
@export var track_rot: float:
	set(to):
		track_rot = to
		if Engine.is_editor_hint() && !preview:
			oval_pos()
@export_range(-21599.94, 21599.94, 0.001, "suffix:°/s") var track_rot_speed: float
@export_group("Special Action")
@export var sound: AudioStream = preload("res://engine/objects/projectiles/sounds/shoot.wav")
@export var ball_throwing_distance: float = 48
@export var ball_speed: float = 350

var tween: Tween

var _origin: Vector2
var _phase: float
var _track_rot: float
var _amplitude: Vector2
var _amplitude_in: bool

@onready var interval: Timer = $Interval


func _draw() -> void:
	if !Engine.is_editor_hint(): return
	elif !Thunder.View.shows_tool(self): return
	
	draw_set_transform(-position, deg_to_rad(track_rot), Vector2.ONE / global_scale)
	var spots: PackedVector2Array = []
	for i in circle_line_spot + 1:
		var dot: Vector2 = Vector2.RIGHT.rotated(float(i) * TAU / float(circle_line_spot)) * amplitude
		spots.append(dot)
	draw_polyline(spots, line_color, 2)


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()
		if !preview:
			return
	oval_pos()
	
	if amplitude_changing_speed > 0 && amplitude_enable:
		if _amplitude_in:
			amplitude = amplitude.move_toward(amplitude_min, amplitude_changing_speed * delta)
			_amplitude_in = !(amplitude == amplitude_min)
		else:
			amplitude = amplitude.move_toward(amplitude_max, amplitude_changing_speed * delta)
			_amplitude_in = (amplitude == amplitude_max)
	
	phase = wrapf(phase + frequency * delta, -180, 180)
	track_rot = wrapf(track_rot + track_rot_speed * delta, -180, 180)
	
	var player: Player = Thunder._current_player
	if !player:
		return
	
	var distance: float = global_position.distance_squared_to(player.global_position)
	if distance < ball_throwing_distance ** 2 && interval.is_stopped():
		interval.start()
		if !tween:
			tween = create_tween().set_loops().set_trans(Tween.TRANS_SINE)
			tween.tween_property(self, "modulate", Color.GOLD, 0.1)
			tween.tween_property(self, "modulate", Color.WHITE, 0.1)

func oval_pos() -> void:
	position = Thunder.Math.oval(Vector2.ZERO, amplitude, deg_to_rad(phase), deg_to_rad(track_rot))


func _on_shooting() -> void:
	var par: Node2D = get_parent()
	Audio.play_sound(sound, par)
	NodeCreator.prepare_2d(PHANTOMIC_BALL, par).call_method(
		func(ball: Projectile) -> void:
			ball.gravity_scale = 0
			ball.global_position = global_position
			var player: Player = Thunder._current_player
			if player:
				ball.speed = global_position.direction_to(player.global_position) * ball_speed
			else:
				ball.speed = Vector2.UP.rotated(randf_range(-PI, PI)) * ball_speed
	).create_2d()
	if tween:
		tween.kill()
		tween = null
