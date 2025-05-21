extends Powerup

signal starman_attacked

@export var active_time_sec: float = 15

var is_equipped: bool
var time_remaining: float
var is_blinking: bool
var at_top: bool
var old_top: bool

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var starman_combo: Combo = Combo.new(self)
@onready var vis: VisibleOnScreenEnabler2D = $VisibleOnScreenEnabler2D

func collect() -> void:
	if is_equipped:
		return
	if score > 0:
		ScoreText.new(str(score), self)
		Data.add_score(score)
	
	vis.queue_free()
	is_equipped = true
	time_remaining = active_time_sec
	body.collision_mask = 0b1110000

	var powerup_sfx = CharacterManager.get_sound_replace(pickup_powerup_sound, DEFAULT_POWERUP_SOUND, "bonus_activate", false)
	Audio.play_sound(powerup_sfx, self, false, {pitch = sound_pitch, ignore_pause = true})
	$Attack.enabled = true


func _physics_process(delta: float) -> void:
	if !is_equipped:
		super(delta)
		return
	
	var pl: Player = Thunder._current_player
	if !pl: return queue_free()
	at_top = floori(time_remaining * 100) % 40 > 20
	
	if at_top:
		global_position = pl.head.global_position - Vector2(0, 12)
		sprite.rotation_degrees = 0
	else:
		global_position = pl.global_position + Vector2(24, 0) * pl.direction
		sprite.rotation_degrees = 90 * pl.direction
	if at_top != old_top:
		reset_physics_interpolation()
		old_top = at_top
	sprite.flip_h = pl.direction < 0
	
	time_remaining = move_toward(time_remaining, 0.0, delta)
	if time_remaining < 3 && !is_blinking:
		is_blinking = true
		Effect.flash($Sprite, 3)
	if time_remaining <= 0.0:
		return queue_free()
	
	#var bricks: bool
	for i in body.get_overlapping_bodies():
		if i is StaticBumpingBlock && i.has_method(&"bricks_break") && !i.get(&"result"):
			i.bricks_break.call_deferred()
			#bricks = true


func _on_attack_killed(what: Node, result: Dictionary) -> void:
	if what == self: return
	# Combo
	if result.result:
		if starman_combo.get_combo() > 0:
			what.sound_pitch = starman_combo.get_pitch()
		#what.got_killed(&"starman", [&"no_score"])
		if what.get("killing_can_combo"):
			starman_combo.combo()
		starman_attacked.emit()
