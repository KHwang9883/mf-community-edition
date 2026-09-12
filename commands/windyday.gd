extends Command

const WIND_NODE = preload("res://stages/extra/expert_mode/objects/world4_3wind.tscn")
const WIND_FX_NODE = preload("res://stages/extra/expert_mode/objects/world4_3wind_fx.tscn")

static func register() -> Command:
	return new().set_name("windyday").set_description("Make every level a *4-3")

func execute(args:Array) -> Command.ExecuteResult:
	if !Scenes.scene_ready.is_connected(patch_level):
		Thunder._connect(Scenes.scene_ready, patch_level)
		patch_level()
		return Command.ExecuteResult.new("Windy Day! (Run this command again to disable)")
	else:
		Thunder._disconnect(Scenes.scene_ready, patch_level)
		if Scenes.is_inside_tree():
			for i in Scenes.get_tree().get_nodes_in_group(&"the_wind"):
				i.queue_free()
		return Command.ExecuteResult.new("Fan is off!")
		

func patch_level() -> void:
	if !Scenes.is_inside_tree() || !Scenes.current_scene is Level:
		return
	if Scenes.get_tree().get_node_count_in_group(&"the_wind") > 0:
		return
	var spawner = WIND_NODE.instantiate()
	var spawner2 = WIND_FX_NODE.instantiate()
	var scene_path: String = Scenes.current_scene.scene_file_path
	Scenes.current_scene.add_child(spawner)
	Scenes.current_scene.add_child(spawner2)
