extends Powerup

const STOPWATCH = preload("res://objects/_clock_item/stopwatch.wav")

func collect() -> void:
	if score > 0:
		ScoreText.new(str(score), self)
		Data.values.score += score
	
	var tw = Scenes.current_scene.create_tween().set_loops()
	tw.tween_interval(0.6)
	tw.tween_callback(Audio.play_1d_sound.bind(STOPWATCH, false, {"volume": 5}))
	Scenes.current_scene.set_meta(&"is_tween", tw)
	get_tree().create_timer(10, false, true, false).timeout.connect(_cancel_stopwatch)
	
	for i in get_tree().get_nodes_in_group(&"end_level_sequence"):
		if i is Projectile:
			if i.belongs_to == Data.PROJECTILE_BELONGS.PLAYER:
				continue
			i.queue_free()
			continue
		if !i.get(&"_center"): continue
		if i._center.has_node(^"../Vision"):
			var vis = i._center.get_node(^"../Vision")
			vis.enable_mode = VisibleOnScreenEnabler2D.ENABLE_MODE_INHERIT
			if vis.is_on_screen():
				i._center.process_mode = Node.PROCESS_MODE_DISABLED
		if i._center.has_node(^"Body"):
			i._center.get_node(^"Body").process_mode = Node.PROCESS_MODE_ALWAYS
		
		#i._center.set_meta("enemy_frozen", i)
		#i._center.process_mode = Node.PROCESS_MODE_DISABLED
		#i.get_parent().process_mode = Node.PROCESS_MODE_ALWAYS

	var powerup_sfx = CharacterManager.get_sound_replace(pickup_powerup_sound, DEFAULT_POWERUP_SOUND, "powerup", true)

	Audio.play_sound(powerup_sfx, self, false, {pitch = sound_pitch, ignore_pause = true})
	queue_free()

func _timed_out() -> void:
	for i in get_tree().get_nodes_in_group(&"end_level_sequence"):
		if i.has_meta(&"enemy_frozen"):
			i.process_mode = Node.PROCESS_MODE_INHERIT
			i.remove_meta(&"enemy_frozen")
			var atk = i.get_meta(&"enemy_frozen")
			if atk:
				atk.process_mode = Node.PROCESS_MODE_INHERIT

## Cancelling Stopwatch Item
func _cancel_stopwatch() -> void:
	Scenes.current_scene.get_meta(&"is_tween").kill()
	for i in get_tree().get_nodes_in_group(&"end_level_sequence"):
		if i.has_node(^"../Vision"):
			var vis = i.get_node(^"../Vision")
			vis.enable_mode = VisibleOnScreenEnabler2D.ENABLE_MODE_INHERIT
			if vis.is_on_screen():
				i.process_mode = Node.PROCESS_MODE_INHERIT
		if i.has_node(^"Body"):
			i.get_node(^"Body").process_mode = Node.PROCESS_MODE_INHERIT
	#timer.stop()
