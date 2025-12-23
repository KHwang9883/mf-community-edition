extends Command


static func register() -> Command:
	return new().set_name("mineinfdev").set_description("Tiles do not get used up. (Requires Mine The Craft Mode. Affects only regular tiles)")

func execute(args:Array) -> Command.ExecuteResult:
	if !Console.cv.get("mc_infinite_tiles", false):
		var gui = Scenes.custom_scenes.get("MinecraftGUI")
		if !is_instance_valid(gui):
			return Command.ExecuteResult.new("[color=red]Error[/color]: Either you are not on a level, or Mine The Craft Mode is not activated: [b]minethecraft[/b].")
		Console.cv.mc_infinite_tiles = true
		#gui.activate_infinite_tiles()
		return Command.ExecuteResult.new("Regular tiles are now infinite.")
	else:
		Console.cv.erase("mc_infinite_tiles")
		#var gui = Scenes.custom_scenes.get("MinecraftGUI")
		#if is_instance_valid(gui):
		#	gui.deactivate_enemy_mode()
		return Command.ExecuteResult.new("Success, OFF")
