extends CanvasLayer

const STOPWATCH = preload("res://engine/objects/items/stopwatch/stopwatch.wav")
const AIMING_LAKITU = preload("res://objects/aiming_lakitu/aiming_lakitu.tscn")

@export var is_expert_mode: bool = true
@export_group("Item Store Settings")
@export var item_store_enabled: bool = true
@export var store_inventory: Dictionary[String, int] = {
	"atom": 1,
	"clock": 2,
	"boomerang": 2,
	"frog": 2,
	"hammer": 2
}
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
var tw2: Tween

var stopwatch_tw: Tween
var stopwatch_active: bool = false

var item: String
var item_need_help: bool = true
var store_cooldown: float

@onready var label: Label = $Label
@onready var item_stock: TextureRect = $Control/ItemStock
@onready var item_stock_help_label: Label = $Control/ItemStock/Label
@onready var label_item_help_text: String = item_stock_help_label.text
@onready var message_block_choicer: AnimatableBody2D = $MessageBlockChoicer

func _ready() -> void:
	item = Data.values.get("item", "")
	item_stock.visible = false
	if item && item_stock.has_node(item):
		item_stock.get_node(item).visible = true
		item_stock.visible = true
		item_stock_help_label.visible = false
	else:
		empty_item_stock()
		item_stock_help_label.visible = false
	
	if ProfileManager.current_profile.data.get("warp_to_save_room"):
		var lvl: Level = Scenes.current_scene
		lvl.completion_write_save = false
		lvl.jump_to_scene = "res://stages/save_game_room/save_game_room.tscn"
	
	reset_physics_interpolation.call_deferred()
	item_stock.reset_physics_interpolation.call_deferred()
	
	if !is_expert_mode: return
	
	if !ProfileManager.current_profile.data.get("mario_forever_expert"):
		SettingsManager.set_tweak("stomping_combo", false)
		SettingsManager.set_tweak("harder_level_design", true)
		SettingsManager.set_tweak("minigames_in_main_worlds", true)
		ProfileManager.current_profile.data["mario_forever_expert"] = true

func _physics_process(delta: float) -> void:
	if store_cooldown > 0.0: store_cooldown -= delta
	var player = Thunder._current_player
	update_item_stock_content()
	
	if player && !player.completed:
		if Input.is_action_just_pressed(&"m_extra") && !Input.is_action_pressed(&"a_tab"):
			if item_stock.has_node(item):
				if tw2: tw2.kill()
				item_need_help = false
				item_stock_help_label.visible = false
				var has_used: bool = item_stock.get_node(item).activate()
				if has_used:
					empty_item_stock()
			else:
				empty_item_stock()
		elif item_store_enabled && store_cooldown <= 0.0:
			if Input.is_action_pressed(&"m_up") && Input.is_action_pressed(&"a_tab"):
				store_cooldown = 0.65
				message_block_choicer.show_message()
				message_block_choicer.process_mode = Node.PROCESS_MODE_ALWAYS
	
	
	if !antiafk_enabled: return
	
	if !player || player.no_movement || player.completed || player.warp != player.Warp.NONE: return
	timer += delta
	
	if (
		(abs(player.speed.x) > 50 || abs(player.speed.y) > 50) &&
		(player.left_right != 0 || player.up_down != 0)
	) || player.jumped:
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
		
	if timer > afk_delay && (called < max_calls || get_tree().get_node_count_in_group(&"antiafk_enemy") < max_calls):
		if timer_2 < call_every:
			timer_2 += delta
		else:
			afk_logic(player)
			timer_2 = 0

func update_item_stock_content() -> void:
	var player = Thunder._current_player
	if !player: return
	if "item" in Data.values && Data.values.item && item != Data.values.item:
		if item_stock.has_node(Data.values.item):
			item = Data.values.item
			item_stock.visible = true
			for i in item_stock.get_children():
				if i is Control:
					i.visible = false
			item_stock.get_node(item).visible = true
			if item_need_help:
				item_stock_help_label.visible = true
				item_stock_help_text()
				item_stock_help_label.modulate.a = 0.5
				tw2 = item_stock_help_label.create_tween()
				tw2.tween_interval(10.0)
				tw2.tween_property(item_stock_help_label, "modulate:a", 0.0, 2.0)
				tw2.tween_callback(item_stock_help_label.hide)
				tw2.tween_property(item_stock_help_label, "modulate:a", 0.5, 0.1)
		else:
			empty_item_stock()

func item_stock_help_text() -> void:
	var _events: Array[InputEvent] = InputMap.action_get_events(&"m_extra")
	var _event: String = "unbinded"
	var _temp: String
	for i in _events:
		if i is InputEventKey:
			_temp = i.as_text().get_slice(' (', 0)
			#if SettingsManager.device_keyboard:
			_event = _temp
			break
		#elif i is InputEventJoypadButton:
		#	_temp = "Joy " + str(i.button_index)
		if _temp: _event = _temp
	
	item_stock_help_label.text = label_item_help_text % [_event]

func empty_item_stock() -> void:
	item = ""
	Data.values.item = ""
	item_stock.visible = false


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
	lak.add_to_group(&"antiafk_enemy")
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
