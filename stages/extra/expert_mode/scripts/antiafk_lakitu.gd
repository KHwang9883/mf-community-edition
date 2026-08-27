extends CanvasLayer

const MESSAGE_BLOCK = preload("res://engine/objects/bumping_blocks/message_block/message_block.wav")
const AIMING_LAKITU = preload("res://objects/aiming_lakitu/aiming_lakitu.tscn")
const MID_LEVEL_ITEM_STORE = preload("res://objects/antiafk_expert_mode/item_store/mid_level_item_store.tscn")

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
var _prev_pause_bool: bool
var active_store: Control

@onready var label: Label = $Label
@onready var item_stock: TextureRect = $Control/ItemStock
@onready var item_stock_help_label: Control = $Control/ItemStock/Label

func _ready() -> void:
	item = Data.values.get("item", "")
	item_stock.visible = false
	if !item:
		var replenished = Data.technical_values.custom_saved_values.get("item_replenisher", "")
		if replenished:
			item = replenished
	if item && item_stock.has_node(item):
		item_stock.get_node(item).visible = true
		item_stock.visible = true
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
			if is_instance_valid(active_store): return
			if Input.is_action_pressed(&"m_up") && Input.is_action_pressed(&"a_tab"):
				store_cooldown = 0.65
				open_item_shop()
	
	
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
				item_stock_help_label.modulate.a = 0.5
				tw2 = item_stock_help_label.create_tween()
				tw2.tween_interval(10.0)
				tw2.tween_property(item_stock_help_label, "modulate:a", 0.0, 2.0)
				tw2.tween_callback(item_stock_help_label.hide)
				tw2.tween_property(item_stock_help_label, "modulate:a", 0.5, 0.1)
		else:
			empty_item_stock()

func empty_item_stock() -> void:
	item = ""
	Data.values.item = ""
	item_stock.visible = false


func open_item_shop() -> void:
	var _sfx = CharacterManager.get_sound_replace(MESSAGE_BLOCK, MESSAGE_BLOCK, "message_box", false)
	Audio.play_1d_sound(_sfx, true, {ignore_pause = true})
	get_tree().paused = true
	
	if "disable_pause_menu" in Scenes.current_scene:
		_prev_pause_bool = Scenes.current_scene.get(&"disable_pause_menu")
		Scenes.current_scene.set(&"disable_pause_menu", true)
	
	var item_store = MID_LEVEL_ITEM_STORE.instantiate()
	item_store.modulate.a = 0.0
	add_child(item_store)
	active_store = item_store
	item_store.antiafk_ref_node = self
	#item_store.msgbox_ref_node = self
	
	for i in item_store.container.get_children():
		if i is TextureRect && !i.name in store_inventory.keys():
			i.queue_free()
	item_store.container._update_selectors()
	var _tw = item_store.create_tween()
	_tw.tween_property(item_store, ^"modulate:a", 1.0, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	_tw.tween_callback(item_store.activate)


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

func return_to_game() -> void:
	#process_mode = Node.PROCESS_MODE_INHERIT
	get_tree().paused = false
	#activated = false
	if "disable_pause_menu" in Scenes.current_scene:
		Scenes.current_scene.set(&"disable_pause_menu", _prev_pause_bool)
