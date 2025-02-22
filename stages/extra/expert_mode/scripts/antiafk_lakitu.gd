extends CanvasLayer

const AIMING_LAKITU = preload("res://objects/aiming_lakitu/aiming_lakitu.tscn")

@export var afk_warning_delay: float = 8
@export var afk_delay: float = 10
@export var call_every: float = 4
@export var max_calls: int = 3

var timer: float
@onready var timer_2: float = call_every
var warned: int
var called: int
var tw: Tween

@onready var label: Label = $Label

func _ready() -> void:
	if !ProfileManager.current_profile.data.get("mario_forever_expert"):
		SettingsManager.set_tweak("stomping_combo", false)
		SettingsManager.set_tweak("harder_level_design", true)
		SettingsManager.set_tweak("minigames_in_main_worlds", true)
		ProfileManager.current_profile.data["mario_forever_expert"] = true

func _physics_process(delta: float) -> void:
	var player = Thunder._current_player
	if !player || player.no_movement || player.completed || player.warp != player.Warp.NONE: return
	timer += delta
	
	if (
		(abs(player.speed.x) > 50 || abs(player.speed.y) > 50) &&
		(player.left_right != 0 || player.up_down != 0)
	) || player.jumped || player.attacked:
		timer = 0
		timer_2 = call_every
		if warned != 0:
			stop_warning()
		warned = 0
		called = 0
		return
	
	if timer > afk_warning_delay && warned == 0:
		warned = 1
		afk_warning()
		
	if timer > afk_delay && called < max_calls:
		if timer_2 < call_every:
			timer_2 += delta
		else:
			afk_logic(player)
			timer_2 = 0


func afk_warning() -> void:
	label.modulate.a = 0.0
	tw = create_tween().set_trans(Tween.TRANS_SINE).set_loops()
	tw.tween_property(label, "modulate:a", 1.0, 0.4)
	tw.tween_property(label, "modulate:a", 0.3, 0.4)

func afk_logic(player: Player) -> void:
	var cam = Thunder._current_camera
	if !cam:
		return
	called += 1
	var lak = AIMING_LAKITU.instantiate()
	lak.does_respawn = false
	lak.pitching_interval_max = 5
	Scenes.current_scene.add_child(lak)
	var rect_size: Vector2 = lak.get_viewport_rect().size
	var cam_pos = cam.get_screen_center_position()
	var random_offset: float = 64 + randf_range(-16, 16)
	lak.position = Vector2(
		cam_pos.x + 24 + rect_size.x / 2,
		clampf(
			player.global_position.y - random_offset,
			(cam_pos.y - rect_size.y / 2) + random_offset,
			(cam_pos.y + rect_size.y / 2) - random_offset
		)
	)
	lak.reset_physics_interpolation()

func stop_warning() -> void:
	if tw: tw.kill()
	label.modulate.a = 0.0
