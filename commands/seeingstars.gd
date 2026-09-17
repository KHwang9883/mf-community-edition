extends Command

var STARFALL = load("res://stages/extra/expert_mode/objects/world3_3starfall.tscn")

static func register() -> Command:
	return new().set_name("seeingstars").set_description("Make every level drop harmful stars from the sky")

func execute(args:Array) -> Command.ExecuteResult:
	if !Scenes.scene_ready.is_connected(patch_level):
		Thunder._connect(Scenes.scene_ready, patch_level)
		patch_level()
		return Command.ExecuteResult.new("Run for your life! (Run this command again to disable)")
	else:
		Thunder._disconnect(Scenes.scene_ready, patch_level)
		if Scenes.is_inside_tree():
			for i in Scenes.get_tree().get_nodes_in_group(&"the_starfall"):
				i.queue_free()
		return Command.ExecuteResult.new("Success, OFF")
		

func patch_level() -> void:
	if !Scenes.is_inside_tree() || !Scenes.current_scene is Level:
		return
	if Scenes.get_tree().get_node_count_in_group(&"the_starfall") > 0:
		return
	var spawner = STARFALL.instantiate()
	#var scene_path: String = Scenes.current_scene.scene_file_path
	Scenes.current_scene.add_child(spawner)
