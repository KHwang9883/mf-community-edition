extends Node

const TOP_ADDONS = [
	preload("res://stages/extra/expert_mode/objects/6_4_mazes/addon_top_1.tscn"),
	preload("res://stages/extra/expert_mode/objects/6_4_mazes/addon_top_2.tscn"),
	preload("res://stages/extra/expert_mode/objects/6_4_mazes/addon_top_3.tscn"),
]
const MIDDLE_ADDONS = [
	preload("res://stages/extra/expert_mode/objects/6_4_mazes/addon_middle_1.tscn"),
	preload("res://stages/extra/expert_mode/objects/6_4_mazes/addon_middle_2.tscn"),
	preload("res://stages/extra/expert_mode/objects/6_4_mazes/addon_middle_3.tscn"),
]
const BOTTOM_ADDONS = [
	preload("res://stages/extra/expert_mode/objects/6_4_mazes/addon_bottom_1.tscn"),
	preload("res://stages/extra/expert_mode/objects/6_4_mazes/addon_bottom_2.tscn"),
	preload("res://stages/extra/expert_mode/objects/6_4_mazes/addon_bottom_3.tscn"),
]

@export_enum("None", "Top", "Middle", "Bottom") var side: int
@export var pos_x_offset: float = 0
@export var block_off_path: bool = false
@export var only_one: bool = false

const INCORRECT = preload("res://sfx/incorrect.wav")
const SELECT_MAIN = preload("res://engine/components/ui/_sounds/select_main.wav")

func _ready() -> void:
	if !only_one: return
	if !"block_pos" in Data.values: return
	if Data.values.checkpoint == -1:
		Data.values.erase("block_pos")
		return
	
	var tile_map_after_cp: TileMapLayer = $"../TileMapAfterCP"
	tile_map_after_cp.visible = true
	tile_map_after_cp.enabled = true
	for i in Data.values.block_pos.keys():
		if !Data.values.block_pos[i]: continue
		var body = Scenes.current_scene.get_node("CPBody%d" % i)
		body.show()
		body.get_node("Collision").set_deferred(&"disabled", false)


func entered() -> void:
	var cam = Thunder._current_camera
	if !cam: return
	cam._retro_tweak = true
	#teleport_by(loop_area_offset)


func teleport_by(pos: float) -> void:
	var player = Thunder._current_player
	if !player: return
	var camera: PlayerCamera2D = Thunder._current_camera
	camera.stop_blocking_edges = true
	camera.set(&"ignore_retro_scroll", true)
	var old_xscroll = camera._xscroll
	player.position.x -= pos
	player.reset_physics_interpolation()
	for i in Scenes.current_scene.get_children():
		if i is Projectile:
			i.position.x -= pos
			i.reset_physics_interpolation()
	for i in get_tree().get_nodes_in_group(&"Trail"):
		i.position.x -= pos
		i.reset_physics_interpolation()
	
	camera.teleport(false, true)
	camera._xscroll = old_xscroll
	camera.teleport(false, false)
	camera.reset_physics_interpolation()
	camera.stop_blocking_edges = false
	camera.set(&"ignore_retro_scroll", false)
	print_verbose("Teleported back by ", pos)


func _play_correct() -> void:
	#var _sfx = CharacterManager.get_sound_replace(SELECT_MAIN, SELECT_MAIN, "menu_select", false)
	Audio.play_1d_sound(SELECT_MAIN, false, {volume = -4})

func _play_incorrect() -> void:
	var _sfx = CharacterManager.get_sound_replace(INCORRECT, INCORRECT, "menu_failure", false)
	Audio.play_1d_sound(_sfx, false)


func _on_player_enter() -> void:
	var addon
	match side:
		1: addon = TOP_ADDONS.pick_random().instantiate()
		2: addon = MIDDLE_ADDONS.pick_random().instantiate()
		3: addon = BOTTOM_ADDONS.pick_random().instantiate()
		_: return
	if pos_x_offset:
		addon.position.x = pos_x_offset
	add_sibling.call_deferred(addon)
	print_verbose(addon.name)
	
	#if loop_area_offset:
		#$"../LoopArea/CollisionShape2D".set_deferred("disabled", false)
	
	if block_off_path:
		if !Data.values.has("block_pos"):
			Data.values.block_pos = {}
		Data.values.block_pos[side] = true
		var body = Scenes.current_scene.get_node("CPBody%d" % side)
		body.show()
		body.get_node("Collision").set_deferred(&"disabled", false)


func _on_level_completed() -> void:
	Data.values.erase("block_pos")
