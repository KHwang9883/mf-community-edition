extends CanvasLayer

const STOPWATCH = preload("res://objects/_clock_item/stopwatch.wav")
const AIMING_LAKITU = preload("res://objects/aiming_lakitu/aiming_lakitu.tscn")

@export var is_expert_mode: bool = true
@export_group("Anti-AFK Settings")
@export var antiafk_enabled: bool = true
@export var afk_warning_delay: float = 8
@export var afk_delay: float = 10
@export var call_every: float = 4
@export var max_calls: int = 3

var timer: float
@onready var timer_2: float = call_every
var warned: int
var called: int
var tw: Tween

var stopwatch_tw: Tween
var stopwatch_active: bool = false

@onready var label: Label = $Label

func _ready() -> void:
	Data.values.stopwatch = 0
	if !is_expert_mode: return
	
	if !ProfileManager.current_profile.data.get("mario_forever_expert"):
		SettingsManager.set_tweak("stomping_combo", false)
		SettingsManager.set_tweak("harder_level_design", true)
		SettingsManager.set_tweak("minigames_in_main_worlds", true)
		ProfileManager.current_profile.data["mario_forever_expert"] = true

func _physics_process(delta: float) -> void:
	var player = Thunder._current_player
	if Data.values.get("stopwatch", 0.0) > 0:
		if !stopwatch_active:
			stopwatch_active = true
			for i in get_tree().get_nodes_in_group(&"end_level_sequence"):
				if i is Projectile:
					if i.belongs_to == Data.PROJECTILE_BELONGS.PLAYER:
						continue
					i.queue_free()
					continue
				if !i.get(&"_center"): continue
				var vis = Thunder.get_child_by_class_name(i._center, "VisibleOnScreenNotifier2D")
				if vis: vis.hide()
				i._center.process_mode = Node.PROCESS_MODE_DISABLED
				if i._center.has_node(^"Body"):
					i._center.get_node(^"Body").process_mode = Node.PROCESS_MODE_ALWAYS
				if i._center.turn_sprite && is_instance_valid(i._center.sprite_node):
					i._center.sprite_node.flip_h = i._center.speed.x < 0
			
			if !stopwatch_tw:
				stopwatch_tw = create_tween().set_loops()
				stopwatch_tw.tween_interval(max(0.2, 0.55 * Engine.time_scale))
				stopwatch_tw.tween_callback(Audio.play_1d_sound.bind(STOPWATCH, false, {"volume": 5}))
		
		Data.values.stopwatch -= delta
		if !player: Data.values.stopwatch = 0
	if stopwatch_active && Data.values.get("stopwatch", 0.0) <= 0:
		_cancel_stopwatch()
	
	if !antiafk_enabled: return
	
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

## Cancelling Stopwatch Item
func _cancel_stopwatch() -> void:
	stopwatch_active = false
	if stopwatch_tw:
		stopwatch_tw.kill()
		stopwatch_tw = null
	for i in get_tree().get_nodes_in_group(&"end_level_sequence"):
		var vis = Thunder.get_child_by_class_name(i._center, "VisibleOnScreenNotifier2D") as VisibleOnScreenNotifier2D
		if vis: vis.show()
		if vis && vis.enable_node_path == vis.get_path_to(i._center):
			if vis.is_on_screen():
				i._center.process_mode = Node.PROCESS_MODE_INHERIT
		else:
			i._center.process_mode = Node.PROCESS_MODE_INHERIT
		if i._center.has_node(^"Body"):
			i._center.get_node(^"Body").process_mode = Node.PROCESS_MODE_INHERIT
