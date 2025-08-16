extends Command

static func register() -> Command:
	return null
	#return new().set_name("makemesmall").set_description("Toggles between tiny-sized player and regular one.")

func execute(args:Array) -> Command.ExecuteResult:
	if !Scenes.scene_ready.is_connected(patch_level):
		Thunder._connect(Scenes.scene_ready, patch_level)
		patch_level()
		return Command.ExecuteResult.new("yuo'er smol now")
	else:
		Thunder._disconnect(Scenes.scene_ready, patch_level)
		for i in get_incoming_connections():
			if !i: continue
			Thunder._disconnect(i.signal, i.callable)
		var pl = Thunder._current_player
		if pl:
			pl.scale = Vector2.ONE
			pl.position.y -= 8
			#Thunder._disconnect(pl.attack.killed, _on_starman_killed)
			#Thunder._disconnect(pl.timer_starman.timeout, _on_starman_timeout)
			#Thunder._disconnect(pl.collided_wall, _on_collided_wall)
			#Thunder._disconnect(pl.collided_floor, _on_collided_floor)
			#Thunder._disconnect(pl.collided_ceiling, _on_collided_ceiling)
			#Thunder._disconnect(pl.get_tree().physics_frame, _physics_frame)
		return Command.ExecuteResult.new("Success, OFF. Restart the level to take effect")
		

func patch_level() -> void:
	if !Scenes.is_inside_tree():
		return
	var pl: Player = Thunder._current_player
	if !pl:
		if Scenes.current_scene.has_node("Player/Player"):
			Scenes.current_scene.get_node("Player/Player").scale = Vector2.ONE / 2
			Scenes.current_scene.get_node("Player/Player").texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		return
	pl.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	pl.scale = Vector2.ONE / 4
	pl.position.y += 8
	
	Thunder._connect(pl.get_tree().physics_frame, _physics_frame)

func _physics_frame() -> void:
	var pl: Player = Thunder._current_player
	if !pl || !Thunder.is_inside_tree(): return
