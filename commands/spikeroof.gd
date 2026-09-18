extends Command

var SPIKEROOF = load("res://stages/extra/hardcore_2/objects/spike_roof.tscn")
const SCENE_PATHS_1: Array[StringName] = [
	&"level_1-3",
	&"expert_level_1-3",
	&"level_5-2",
	&"level_8-4_boss",
	&"expert_level_8-4_boss",
	&"level_f1-4",
	&"level_f2-2",
	&"level_f2-4",
	&"level_f3-3",
	&"level_f4-4",
	&"level_u-3",
	&"level_u-4-3",
	&"level_u-4_e",
	&"level_u-4_n",
	&"level_u-4_h",
	&"level_12-1",
	&"level_10-3",
	&"level_13-1",
	&"level_9-4",
	&"level_9-5",
	&"level_s1-3",
	&"level_s2-2",
	&"level_s2-3",
	&"level_s2-4",
	&"level_s3-1",
	&"level_s3-4",
	&"level_s4-2",
	&"level_s4-3",
	&"funny_tanks",
	&"level_ny_2",
	&"level_ny_3",
	&"level_ny_4-2",
	&"lost_map_1",
	&"lost_map_3",
	&"lost_map_5",
	&"human_lab2-2",
	&"human_lab2-4",
	&"human_lab-3",
	&"hardcore_2-1",
	&"hardcore_1-1",
]
const SCENE_PATHS_2: Array[StringName] = [
	&"level_8-1",
	&"expert_level_8-1",
	&"expert_level_4-3",
	&"level_1-4",
	&"level_2-5",
	&"level_3-4",
	&"level_4-4",
	&"level_6-4",
	&"level_f3-4",
	&"expert_level_1-4",
	&"expert_level_2-5",
	&"expert_level_3-4",
	&"expert_level_4-4",
	&"expert_level_6-4",
	&"level_f4-2",
	&"stupidity-3",
	&"level_13-2",
	&"level_13-3",
	&"level_12-2",
	&"level_10-4",
	&"level_s1-4",
	&"devastator",
	&"starman_running",
	&"lost_map_6",
	&"human_lab2-5",
	&"hardcore_2-4",
	&"hardcore_1-4",
]
const SCENE_PATHS_3: Array[StringName] = [
	&"expert_level_5-2",
	&"level_s3-3",
	&"koopa_troopa_liberation",
]
const SCENE_PATHS_4: Array[StringName] = [
	&"level_f2-1",
]
const SCENE_PATHS_5: Array[StringName] = [
	&"human_lab-4",
	&"human_lab-jeansowaty",
]
const SCENE_PATCHES: Dictionary[Array, float] = {
	SCENE_PATHS_1: 288.0,
	SCENE_PATHS_2: 224.0,
	SCENE_PATHS_3: 160.0,
	SCENE_PATHS_4: 352.0,
}

static func register() -> Command:
	return new().set_name("spikeroof").set_description("Make every level have a Hardcore 2-3 spike roof")

func execute(args:Array) -> Command.ExecuteResult:
	if !Scenes.scene_ready.is_connected(patch_level):
		Thunder._connect(Scenes.scene_ready, patch_level)
		patch_level()
		return Command.ExecuteResult.new("Heavy skies... (Run this command again to disable)")
	else:
		Thunder._disconnect(Scenes.scene_ready, patch_level)
		if Scenes.is_inside_tree():
			for i in Scenes.get_tree().get_nodes_in_group(&"spikeroof"):
				i.queue_free()
		return Command.ExecuteResult.new("Success, OFF")
		

func patch_level() -> void:
	if !Scenes.is_inside_tree() || !Scenes.current_scene is Level:
		return
	if Scenes.get_tree().get_node_count_in_group(&"spikeroof") > 0:
		return
	var scene_path: String = Scenes.current_scene.scene_file_path
	if "save_game_room" in scene_path || "main_menu" in scene_path:
		return
	
	var spawner: Parallax2D = SPIKEROOF.instantiate()
	var spike_ceiling: VBoxContainer = spawner.get_child(0)
	_disable_spike_hazard(spike_ceiling)
	
	var keys: Array = SCENE_PATCHES.keys()
	var values: Array = SCENE_PATCHES.values()
	for i in SCENE_PATCHES.size():
		if keys[i].any(_is_in_scene_path.bind(scene_path)):
			spike_ceiling.bottom_line_position = values[i]
	
	if SCENE_PATHS_5.any(_is_in_scene_path.bind(scene_path)):
		var left_spike_wall = _set_side_spikes(spawner, spike_ceiling)
		spawner.scroll_scale.x = 1
		spike_ceiling.position.x += 160
		spike_ceiling.bottom_line_position += 160 - 32
		left_spike_wall.bottom_line_position += 32
		var layer_2: TileMapLayer = Scenes.current_scene.get_node_or_null("Layer2") as TileMapLayer
		if layer_2:
			layer_2.erase_cell(Vector2i(1, 107))
			layer_2.erase_cell(Vector2i(2, 107))
	#if SCENE_PATHS_5.any(_is_in_scene_path.bind(scene_path)):
	#	spawner.scroll_scale.y = 0
	
	spawner.add_to_group(&"spikeroof")
	Scenes.current_scene.add_child(spawner)

func _is_in_scene_path(path: StringName, scene_path: String) -> bool:
	return path in scene_path


func _set_side_spikes(spawner: Parallax2D, spike_ceiling: VBoxContainer) -> VBoxContainer:
	spawner.repeat_size.x = 0
	spike_ceiling.rotation_degrees = 90
	spike_ceiling.position = Vector2(496, -48)
	spike_ceiling.bottom_line_position = 384
	spike_ceiling.activated_area.position.y = -15000
	spike_ceiling.activated_area.size.y = 40000
	
	var left_spike_wall: VBoxContainer = spike_ceiling.duplicate()
	left_spike_wall.rotation_degrees = -90
	left_spike_wall.position = Vector2(-496, -48)
	left_spike_wall.bottom_line_position = 256
	left_spike_wall.activated_area.position.y = -15000
	left_spike_wall.activated_area.size.y = 40000
	_disable_spike_hazard(left_spike_wall)
	spawner.add_child.call_deferred(left_spike_wall)
	return left_spike_wall


func _disable_spike_hazard(spike_ceiling: Node) -> void:
	spike_ceiling.set_physics_process(false)
	var spike_area := spike_ceiling.get_node_or_null(^"Spike/Area2D") as Area2D
	if spike_area:
		spike_area.monitoring = false
		spike_area.set_physics_process(false)


func _set_spike_floor(spawner: Parallax2D, spike_ceiling: VBoxContainer) -> void:
	spike_ceiling.rotation_degrees = 180
	spike_ceiling.position.y = 448
	spike_ceiling.bottom_line_position = 104
	spike_ceiling.activated_area.position.y = -960
	spike_ceiling.activated_area.size.y = 4000
	
