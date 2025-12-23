extends Command


static func register() -> Command:
	return new().set_name("evilminecraft").set_description("Grab your enemies on the go. (Requires Mine The Craft Mode)")

func execute(args:Array) -> Command.ExecuteResult:
	if !Console.cv.get("mc_enemy_mode", false):
		var gui = Scenes.custom_scenes.get("MinecraftGUI")
		if !is_instance_valid(gui):
			return Command.ExecuteResult.new("[color=red]Error[/color]: Either you are not on a level, or Mine The Craft Mode is not activated: [b]minethecraft[/b].")
		Console.cv.mc_enemy_mode = true
		gui.activate_enemy_mode()
		return Command.ExecuteResult.new("You can now break enemies using the mouse.")
	else:
		Console.cv.erase("mc_enemy_mode")
		var gui = Scenes.custom_scenes.get("MinecraftGUI")
		if is_instance_valid(gui):
			gui.deactivate_enemy_mode()
		return Command.ExecuteResult.new("Success, OFF")
