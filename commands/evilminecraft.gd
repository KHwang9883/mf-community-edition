extends Command


static func register() -> Command:
	return new().set_name("evilminecraft").set_description("Grab your enemies on the go. (Requires Minecraft Mode)")

func execute(args:Array) -> Command.ExecuteResult:
	if !Console.cv.get("mc_enemy_mode", false):
		var gui = Scenes.custom_scenes.get("MinecraftGUI")
		if !is_instance_valid(gui):
			return Command.ExecuteResult.new("Error: Activate Minecraft Mode first: [b]minethecraft[/b].")
		Console.cv.mc_enemy_mode = true
		gui.activate_enemy_mode()
		return Command.ExecuteResult.new("You can now break enemies using the mouse.")
	else:
		Console.cv.erase("mc_enemy_mode")
		var gui = Scenes.custom_scenes.get("MinecraftGUI")
		if is_instance_valid(gui):
			gui.deactivate_enemy_mode()
		return Command.ExecuteResult.new("Success, OFF")
