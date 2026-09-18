extends Command

var GENERATOR = load("res://stages/extra/expert_mode/objects/bowserflame_generator.tscn")
var GENERATOR_TRIGGER = load("res://stages/extra/expert_mode/objects/bowserflame_gen_trigger.tscn")

static func register() -> Command:
	return new().set_name("firewall").set_description("Make every level an Expert Bowser appearance") \
	.set_debug() # command is unfinished, so only debug builds can access it

func execute(args:Array) -> Command.ExecuteResult:
	if !Scenes.scene_ready.is_connected(patch_level):
		Thunder._connect(Scenes.scene_ready, patch_level)
		patch_level()
		return Command.ExecuteResult.new("Firewall! (Run this command again to disable)")
	else:
		Thunder._disconnect(Scenes.scene_ready, patch_level)
		if Scenes.is_inside_tree():
			for i in Scenes.get_tree().get_nodes_in_group(&"bowser_flame_gen"):
				i.queue_free()
		return Command.ExecuteResult.new("Success, OFF")
		

func patch_level() -> void:
	if !Scenes.is_inside_tree() || !Scenes.current_scene is Level:
		return
	if Scenes.get_tree().get_node_count_in_group(&"bowser_flame_gen") > 0:
		return
	var scene_path: String = Scenes.current_scene.scene_file_path
	if "save_game_room" in scene_path || "main_menu" in scene_path:
		return
	
	var generator = GENERATOR.instantiate()
	var generator_trigger = GENERATOR_TRIGGER.instantiate()
	Scenes.current_scene.add_child(generator)
	Scenes.current_scene.add_child(generator_trigger)
