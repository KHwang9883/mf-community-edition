extends Command

var CHEEP_SPAWNER = load("res://commands/objects/jumping_cheeps_generator.tscn")
var HUMAN_FISH = load("res://objects/human_lab_2/swimming/cheep_closed_fishman/cheep_closed_fishman_jumping.tscn")
const SCENE_PATHS: Array[StringName] = [
	&"human_lab",
	&"level_ny_",
	&"_u/hidden/extralevel_2",
	&"_u/hidden/extralevel_3",
	&"MisiekMomento",
	&"human_lava_run",
]

static func register() -> Command:
	return new().set_name("thefish").set_description("Make every level a 2-2!!!")

func execute(args:Array) -> Command.ExecuteResult:
	if !Scenes.scene_ready.is_connected(patch_level):
		Thunder._connect(Scenes.scene_ready, patch_level)
		patch_level()
		return Command.ExecuteResult.new("Thanks for all the fish! (Run this command again to disable)")
	else:
		Thunder._disconnect(Scenes.scene_ready, patch_level)
		if Scenes.is_inside_tree():
			for i in Scenes.get_tree().get_nodes_in_group(&"cheep_gen_cheat"):
				i.queue_free()
		return Command.ExecuteResult.new("So long! (OFF)")
		

func patch_level() -> void:
	if !Scenes.is_inside_tree() || !Scenes.current_scene is Level:
		return
	if Scenes.get_tree().get_node_count_in_group(&"cheep_gen_cheat") > 0:
		return
	var scene_path: String = Scenes.current_scene.scene_file_path
	if "save_game_room" in scene_path || "main_menu" in scene_path:
		return
		
	var spawner = CHEEP_SPAWNER.instantiate()
	if SCENE_PATHS.any(func(path: StringName):
		return path in scene_path
	):
		spawner.cheep_scene = HUMAN_FISH
	Scenes.current_scene.add_child(spawner)
