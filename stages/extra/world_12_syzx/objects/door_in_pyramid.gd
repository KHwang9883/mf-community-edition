@tool
extends "res://engine/objects/warps/door/door_in.gd"

var _fix_walking_player_anim: bool

func _ready() -> void:
	super()
	if Engine.is_editor_hint(): return
	_target = 0.02

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()
		return
	if !player: return
	if _fix_walking_player_anim:
		player.sprite.play(&"default")
	
	var input_y: int = int(Input.get_axis(player.control.up, player.control.down))
	
	if player.is_on_floor() && !_on_warp && player.warp == Player.Warp.NONE && \
	!(&"holding" in player.suit.extra_vars && player.suit.extra_vars.is_holding) && \
	player.global_position.y <= pos_player.global_position.y + 8:
		if input_y < 0:
			_on_warp = true
			#pos_player.position = Vector2(0, (shape.shape as RectangleShape2D).size.y - (player.collision_shape.shape as RectangleShape2D).size.y + 16)
		
		if _on_warp:
			#sprite.z_index = 1
			#sprite.play(&"open")
			#sprite_bg.z_index = 1
			#sprite_bg.visible = true
			warp_started.emit()
			
			player.warp = Player.Warp.IN
			@warning_ignore("int_as_enum_without_cast")
			player.warp_dir = int(player.direction > 0)
			#player.global_position = pos_player.global_position
			#player.sync_position()
			player.speed = Vector2.ZERO
			Audio.play_sound(warping_sound, self, false)
			Thunder._current_hud.timer.paused = true
	
	if !_on_warp: return
	
	if _duration < _target:
		#player.global_position = pos_player.global_position
		#player.sync_position()
		player.sprite.play(&"default")
		_duration += delta
	
	# Warping Transition
	elif !_warp_triggered:
		_warp_triggered = true
		
		if use_circle_transition:
			_circle_transition()
		
		elif use_blur_transition:
			var trans = load(
				"res://engine/components/transitions/blur_transition/blur_transition.tscn"
			).instantiate()
			trans.speed_closing = blur_closing_speed
			trans.speed_opening = -blur_opening_speed
			
			TransitionManager.accept_transition(trans)
			_fix_walking_player_anim = true
			player.sprite.play(&"default")
			await TransitionManager.transition_middle
			TransitionManager.current_transition.paused = true
			
			pass_warp()
			_fix_walking_player_anim = false
			await get_tree().physics_frame
			
			TransitionManager.current_transition.paused = false
		else: pass_warp()


func pass_warp() -> void:
	var _m = target.sprite_bg.create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	_m.tween_property(target.sprite_bg, "self_modulate:a", 0.0, 1.28)
	super()
