extends GeneralMovementBody2D

const STAR_EFFECT = preload("res://stages/extra/click_bonus_game/textures/star_effect.png")

const BREAK = preload("res://engine/objects/bumping_blocks/_sounds/break.wav")
const EXPLOSION = preload("res://engine/objects/effects/explosion/explosion.tscn")

func _ready() -> void:
	var tw = create_tween().set_loops()
	tw.tween_property(sprite_node, "rotation_degrees", -360, 0.6)
	tw.tween_callback(func():
		sprite_node.rotation_degrees = 0.0
		sprite_node.reset_physics_interpolation()
	)
	get_tree().create_timer(6.0, false, true).timeout.connect(queue_free)


func _on_trail() -> void:
	if SettingsManager.get_quality() == SettingsManager.QUALITY.MIN:
		return
	var trail = Effect.trail(self, sprite_node.texture, Vector2.ZERO, sprite_node.flip_h, false, true, 0.12, 0.25)
	trail.rotation = sprite_node.rotation
	Thunder.reorder_on_top_of(trail, self)


func _physics_process(delta: float) -> void:
	if is_queued_for_deletion(): return
	super(delta)
	
	if is_on_floor() || is_on_wall() || is_zero_approx(speed.x):
		Audio.play_sound(BREAK, self, false)
		var expl = EXPLOSION.instantiate()
		expl.position = global_position
		Scenes.current_scene.add_child(expl)
		queue_free()
		var trail = Effect.trail(self, STAR_EFFECT, Vector2.ZERO, false, false, true, 0.025, 1.5)
		_effect_tweener(trail, -128)
		var trail2 = Effect.trail(self, STAR_EFFECT, Vector2.ZERO, false, false, true, 0.025, 1.5)
		_effect_tweener(trail2, 128)


func _effect_tweener(trail: Sprite2D, offset: float) -> void:
	var tw = trail.create_tween().set_loops()
	tw.tween_property(trail, "rotation_degrees", -360, 0.4)
	tw.tween_callback(func():
		trail.rotation_degrees = 0.0
		trail.reset_physics_interpolation()
	)
	var old_pos = trail.position
	var tw2 = trail.create_tween().set_trans(Tween.TRANS_SINE)
	tw2.tween_property(trail, "position:y", old_pos.y - 24, 0.25).set_ease(Tween.EASE_OUT)
	tw2.tween_property(trail, "position:y", old_pos.y + 96, 1.0).set_ease(Tween.EASE_IN)
	trail.create_tween().tween_property(trail, "position:x", old_pos.x + offset, 1.5)
