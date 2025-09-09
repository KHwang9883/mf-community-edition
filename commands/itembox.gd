extends Command

const ANTIAFK = preload("res://objects/antiafk_expert_mode/antiafk_expert_mode.tscn")
var antiafk_ref

static func register() -> Command:
	return new().set_name("itembox").set_description("Allow any level to have an Item Box.")

func execute(args:Array) -> Command.ExecuteResult:
	if !Scenes.scene_ready.is_connected(patch_level):
		Thunder._connect(Scenes.scene_ready, patch_level)
		patch_level()
		return Command.ExecuteResult.new("Success, ON. Press both Up and Tab to open the item shop.")
	else:
		Thunder._disconnect(Scenes.scene_ready, patch_level)
		if Scenes.is_inside_tree() && is_instance_valid(antiafk_ref):
			antiafk_ref.queue_free()
		return Command.ExecuteResult.new("Success, OFF.")
		

func patch_level() -> void:
	if !Scenes.is_inside_tree() || !Scenes.current_scene is Level:
		return
	if Scenes.get_tree().get_node_count_in_group(&"antiafk_node") > 0:
		return
	var spawner = ANTIAFK.instantiate()
	spawner.is_expert_mode = false
	spawner.antiafk_enabled = false
	spawner.store_inventory.clock = 2
	Scenes.current_scene.add_child(spawner)
	antiafk_ref = spawner
