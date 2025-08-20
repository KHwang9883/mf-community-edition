extends Command

static func register() -> Command:
	return new().set_name("iceedition").set_description("All surfaces are slippery, acceleration decreased.")

func execute(args:Array) -> Command.ExecuteResult:
	if !Scenes.scene_ready.is_connected(patch_level):
		Thunder._connect(Scenes.scene_ready, patch_level)
		patch_level()
		return Command.ExecuteResult.new("Now playing: Mario Forever, but the Floor is Ice.")
	else:
		Thunder._disconnect(Scenes.scene_ready, patch_level)
		if Thunder._current_player:
			var pl = Thunder._current_player
			if pl.has_node("SlipperyPhysicsModifier"):
				pl.get_node("SlipperyPhysicsModifier").scene_group_name = "slippery"
		return Command.ExecuteResult.new("Success, OFF")
		

func patch_level() -> void:
	if !Scenes.is_inside_tree():
		return
	
	var pl: Player = Thunder._current_player
	if !pl:
		return
	
	if pl.has_node("SlipperyPhysicsModifier"):
		pl.get_node("SlipperyPhysicsModifier").scene_group_name = ""
		return
