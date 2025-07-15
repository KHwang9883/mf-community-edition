extends "res://engine/objects/bosses/bowser/attacks/bowser_attack_bullet.gd"

func _physics_process(delta: float) -> void:
	if !launcher:
		return
	super(delta)
	var pl := Thunder._current_player
	if !pl: return
	
	launcher.look_at(pl.global_position)
	var real_rot = wrapf(launcher.rotation, 0, TAU)
	launcher.flip_v = real_rot > PI/2 && real_rot < 3*PI/2

func middle_attack() -> void:
	middle.emit()
	if !bullet_bill: return
	if !Thunder._current_player: return
	
	Audio.play_sound(
		shooting_sound, pos_bullet, false, {
			"pitch": randf_range(sound_pitch_min, sound_pitch_max),
			"volume": sound_volume,
		}
	)
	NodeCreator.prepare_ins_2d(bullet_bill, bowser).call_method(
		func(bul: Node2D) -> void:
			if bul is GeneralMovementBody2D:
				bul.look_at_player = false
				bul.turn_sprite = false
				bul.dir = 1
	).create_2d(false).call_method(
		func(bul: Node2D) -> void:
			bul.global_transform = pos_bullet.global_transform
			if bul is GeneralMovementBody2D:
				var real_rot = wrapf(bul.rotation, 0, TAU)
				bul.sprite_node.flip_v = real_rot > PI/2 && real_rot < 3*PI/2
				bul.set_meta(&"added_speed_angle", Vector2.from_angle(bul.rotation))
				bul.vel_set(Vector2.from_angle(bul.rotation) * bullet_speed)
				if bul.has_method(&"set_self_modulate_back") && is_instance_valid(bul.sprite_node):
					bul.sprite_node.self_modulate.a = 0.0
					bul.set_self_modulate_back()
				var enemy_attacked: Node = bul.get_node_or_null("Body/EnemyAttacked")
				if enemy_attacked:
					enemy_attacked.stomping_standard = enemy_attacked.stomping_standard.rotated(-bul.global_rotation)
	)
	NodeCreator.prepare_2d(explosion, pos_bullet).create_2d().bind_global_transform(Vector2.from_angle(launcher.rotation) * 16 * bowser.facing)
	end_attack()
