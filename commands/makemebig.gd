extends Command

const debris_effect = preload("res://engine/objects/effects/brick_debris/brick_debris_grey.tscn")
const BREAK = preload("res://engine/objects/bumping_blocks/_sounds/break.wav")

var how_many_floor_tiles_to_break: int

static func register() -> Command:
	return new().set_name("makemebig").set_description("IT'S. TOO. BIG. Toggles between huge-sized player and regular one.")

func execute(args:Array) -> Command.ExecuteResult:
	if !Scenes.scene_ready.is_connected(patch_level):
		Thunder._connect(Scenes.scene_ready, patch_level)
		patch_level()
		return Command.ExecuteResult.new("NOW IS YOUR OPPORTUNITY TO BECOME A")
	else:
		Thunder._disconnect(Scenes.scene_ready, patch_level)
		for i in get_incoming_connections():
			if !i: continue
			Thunder._disconnect(i.signal, i.callable)
		#if Thunder._current_player:
			#var pl = Thunder._current_player
			#Thunder._disconnect(pl.attack.killed, _on_starman_killed)
			#Thunder._disconnect(pl.timer_starman.timeout, _on_starman_timeout)
			#Thunder._disconnect(pl.collided_wall, _on_collided_wall)
			#Thunder._disconnect(pl.collided_floor, _on_collided_floor)
			#Thunder._disconnect(pl.collided_ceiling, _on_collided_ceiling)
			#Thunder._disconnect(pl.get_tree().physics_frame, _physics_frame)
		return Command.ExecuteResult.new("It was just too big. (Restart the level to take effect)")
		

func patch_level() -> void:
	if !Scenes.is_inside_tree():
		return
	how_many_floor_tiles_to_break = 0
	var pl: Player = Thunder._current_player
	if !pl:
		if Scenes.current_scene.has_node("Player/Player"):
			Scenes.current_scene.get_node("Player/Player").scale = Vector2.ONE * 2
			Scenes.current_scene.get_node("Player/Player").texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		return
	pl.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	pl.scale = Vector2.ONE * 4
	pl.position.y -= 48
	pl.attack.enabled = true
	
	Thunder._connect(pl.attack.killed, _on_starman_killed)
	Thunder._connect(pl.timer_starman.timeout, _on_starman_timeout)
	Thunder._connect(pl.collided_wall, _on_collided_wall)
	Thunder._connect(pl.collided_floor, _on_collided_floor)
	Thunder._connect(pl.collided_ceiling, _on_collided_ceiling)
	Thunder._connect(pl.get_tree().physics_frame, _physics_frame)

func _on_starman_killed(what: Node, result: Dictionary) -> void:
	if !Thunder._current_player.is_starman():
		Thunder._current_player.starman_combo.reset_combo()

func _on_starman_timeout() -> void:
	Thunder._current_player.attack.enabled = true

func _physics_frame() -> void:
	var pl: Player = Thunder._current_player
	if !pl || !Thunder.is_inside_tree(): return
	if pl.timer_invincible.is_inside_tree() && pl.timer_invincible.is_stopped():
		pl.timer_invincible.start(500.0)
	pl.attack.killing_detection_scale = 1
	pl.attack.enabled = true
	if how_many_floor_tiles_to_break > 0:
		var clamped = clampf(
			16 * how_many_floor_tiles_to_break * (-1 if how_many_floor_tiles_to_break % 2 == 0 else 1), -48, 48
		)
		if pl.is_on_floor():
			_tile_break_logic(Vector2(clamped, 1))
		how_many_floor_tiles_to_break -= 1

func _on_collided_wall() -> void:
	_tile_break_logic(-Vector2.ONE)

func _on_collided_floor() -> void:
	var speed_prev: float = Thunder._current_player.speed_previous.y
	if speed_prev > 150:
		_tile_break_logic(Vector2(0, 1))
	if speed_prev > 300:
		how_many_floor_tiles_to_break += 1 + int(speed_prev > 350) + int(speed_prev > 415) + int(speed_prev > 480)
		how_many_floor_tiles_to_break = mini(how_many_floor_tiles_to_break, 5)

func _on_collided_ceiling() -> void:
	if Thunder._current_player.speed_previous.y < 20:
		_tile_break_logic(Vector2(0, -1))

func _tile_break_logic(offset: Vector2) -> void:
	var pl := Thunder._current_player
	if !pl: return
	var col := pl.get_last_slide_collision()
	if !col: return
	var collider = col.get_collider()
	if !collider: return
	var which_wall = pl.get_which_wall_collided()
	var col_pos: Vector2 = col.get_position()
	if collider is TileMapLayer:
		if offset == -Vector2.ONE:
			col_pos += offset * -which_wall
		else:
			col_pos += offset
		var tile_pos = collider.local_to_map(collider.to_local(col_pos))
		#print(tile_pos)
		if !collider.get_cell_tile_data(tile_pos):
			return
		collider.set_cell(tile_pos)
		tile_break(collider, collider.to_global(collider.map_to_local(tile_pos)))
	elif collider is TileMap:
		if offset == -Vector2.ONE:
			col_pos += offset * -which_wall
		else:
			col_pos += offset
		var tile_pos = collider.local_to_map(collider.to_local(col_pos))
		for i in collider.get_layers_count():
			var tdata: TileData = collider.get_cell_tile_data(i, tile_pos)
			if !tdata: continue
			if tdata.get_collision_polygons_count(i) == 0: continue
			collider.set_cell(i, tile_pos)
			tile_break(collider, collider.to_global(collider.map_to_local(tile_pos)))
	elif collider is StaticBumpingBlock:
		if collider.has_method(&"bricks_break"):
			collider.bricks_break()
		else:
			tile_break(collider, collider.global_position)
			collider.hide()
			collider.set_deferred(&"collision_layer", 0)
			collider.process_mode = Node.PROCESS_MODE_DISABLED
			#collider.queue_free()
	else:
		var shape = col.get_collider_shape()
		if shape is CollisionShape2D:
			if shape.shape && shape.shape.get_rect().size.x > 300:
				return
		elif shape is CollisionPolygon2D:
			var count = shape.polygon.size()
			for i in mini(count, 12):
				if shape.polygon.get(i)[shape.polygon.get(i).max_axis_index()] > 149:
					return
		tile_break(collider, collider.global_position)
		collider.hide()
		collider.set_deferred(&"collision_layer", 0)
		collider.process_mode = Node.PROCESS_MODE_DISABLED
		#print(collider)


func tile_break(what: Node2D, pos: Vector2) -> void:
	Audio.play_sound(BREAK, Thunder._current_player)
	var speeds = [Vector2(2, -8), Vector2(4, -7), Vector2(-2, -8), Vector2(-4, -7)]
	for i in speeds:
		NodeCreator.prepare_2d(debris_effect, what).create_2d(true).call_method(func(eff: Node2D):
			eff.global_transform = what.global_transform
			eff.global_position = pos
			eff.velocity = i
		)
		
	Data.add_score(10)
