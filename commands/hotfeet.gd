extends Command

const BURNING_SURFACE = preload("res://objects/burning_surface_modifier/burning_surface.tscn")
const BURNING_SURFACE_MODIFIER = preload("res://objects/burning_surface_modifier/burning_surface_modifier.tscn")

static func register() -> Command:
	return new().set_name("hotfeet").set_description("All surfaces act like magma. Keep jumping!")

func execute(args:Array) -> Command.ExecuteResult:
	if !Scenes.scene_ready.is_connected(patch_level):
		Thunder._connect(Scenes.scene_ready, patch_level)
		patch_level()
		return Command.ExecuteResult.new("It Burns! Ow! Stop! Help Me! It Burns!")
	else:
		Thunder._disconnect(Scenes.scene_ready, patch_level)
		if Thunder._current_player:
			var pl = Thunder._current_player
			if pl.has_node("BurningSurfaceModifier"):
				pl.get_node("BurningSurfaceModifier").queue_free()
			if pl.has_node("BurningSurface"):
				pl.get_node("BurningSurface").queue_free()
		return Command.ExecuteResult.new("Success, OFF")
		

func patch_level() -> void:
	if !Scenes.is_inside_tree():
		return
	
	var pl: Player = Thunder._current_player
	if !pl:
		return
	
	if pl.has_node("BurningSurfaceModifier"):
		pl.get_node("BurningSurfaceModifier").scene_group_name = ""
		return
	var surface = BURNING_SURFACE.instantiate()
	pl.add_child.call_deferred(surface, true)
	var modifier = BURNING_SURFACE_MODIFIER.instantiate()
	modifier.scene_group_name = ""
	pl.add_child.call_deferred(modifier, true)
