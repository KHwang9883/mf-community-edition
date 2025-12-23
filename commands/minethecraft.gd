extends Command

#const debris_effect = preload("res://engine/objects/effects/brick_debris/brick_debris_grey.tscn")
#const BREAK = preload("res://engine/objects/bumping_blocks/_sounds/break.wav")
const MINECRAFT_LAYER = preload("res://commands/minec/minecraft_layer.tscn")
const OUTLINE_DRAW = preload("res://commands/minec/outline_draw.tscn")


static func register() -> Command:
	return new().set_name("minethecraft").set_description("Mine The Craft mode. (Mouse required)")

func execute(args:Array) -> Command.ExecuteResult:
	if !Scenes.scene_ready.is_connected(patch_level):
		Thunder._connect(Scenes.scene_ready, patch_level)
		patch_level()
		return Command.ExecuteResult.new("You can now break blocks using the mouse. Press Tab to switch hotbars; middle click to drop items.")
	else:
		Thunder._disconnect(Scenes.scene_ready, patch_level)
		for i in get_incoming_connections():
			if !i: continue
			Thunder._disconnect(i.signal, i.callable)
		if Thunder._current_player:
			var pl = Thunder._current_player
			if pl.has_node("OutlineDraw"):
				pl.get_node("OutlineDraw").queue_free()
			var gui = Scenes.custom_scenes.get("MinecraftGUI")
			if is_instance_valid(gui):
				gui.queue_free()
		return Command.ExecuteResult.new("Success, OFF")
		

func patch_level() -> void:
	if !Scenes.is_inside_tree():
		return
	
	SettingsManager.show_mouse()
	var pl: Player = Thunder._current_player
	if !pl:
		return
	Thunder._connect(pl.get_tree().physics_frame, _physics_frame)
	
	var outline_draw = OUTLINE_DRAW.instantiate()
	pl.add_child(outline_draw)
	var mclayer = MINECRAFT_LAYER.instantiate()
	Scenes.current_scene.add_child(mclayer)

func _physics_frame() -> void:
	if SettingsManager.mouse_mode == Input.MouseMode.MOUSE_MODE_HIDDEN:
		SettingsManager.show_mouse()
