extends GeneralMovementBody2D

const DEBRIS_EFFECT = preload("res://objects/grabbable_brick/brick_debris/grabbable_brick_debris.tscn")
const break_sound = preload("res://engine/objects/bumping_blocks/_sounds/break.wav")

var result: PackedScene

var constant_speed: float
var cooldown: float = 0.3

@onready var combo: Combo = Combo.new(self)

func _physics_process(delta: float) -> void:
	super(delta)
	if cooldown >= 0:
		cooldown -= delta
	if is_on_floor() && constant_speed == 0:
		bricks_break()
		return
	if constant_speed > 0 && !is_on_wall():
		speed.x = constant_speed
	


func got_side_grabbed() -> void:
	if !result: return
	if cooldown >= 0: return
	var player: Player = Thunder._current_player as Player
	if !player: return
	var based: Node2D = result.instantiate() as Node2D
	player.add_child(based)
	based.z_index = 1
	player.suit.extra_vars.holding = based
	Audio.play_sound(player.suit.grab_sound_grab, player, false)
	
	queue_free()


func bricks_break() -> void:
	Audio.play_sound(break_sound, self)
	for i in get_slide_collision_count():
		var j: KinematicCollision2D = get_slide_collision(i)
		var collider = j.get_collider()
		if collider is StaticBumpingBlock:
			if collider.has_method(&"got_bumped"):
				collider.got_bumped.call_deferred(self)
			elif collider.has_method(&"bricks_break"):
				collider.bricks_break.call_deferred()
	var speeds = [Vector2(2, -8), Vector2(4, -7), Vector2(-2, -8), Vector2(-4, -7)]
	for i in speeds:
		NodeCreator.prepare_2d(DEBRIS_EFFECT, self).create_2d(true).call_method(func(eff: Node2D):
			eff.global_transform = global_transform
			eff.velocity = i
		)
		
	queue_free()


func _on_attack_killed(what: Node, _result: Dictionary) -> void:
	if what == self: return
	# Combo
	if _result.result:
		if !what.get("killing_can_combo"):
			return
		if !combo.get_combo() <= 0:
			what.sound_pitch = 1 + combo.get_combo() * 0.135
		combo.combo()
