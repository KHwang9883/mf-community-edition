extends Node

const INTRO_CASTLE_CRUSH_2 = preload("res://engine/scenes/castle_cutscene/sounds/castle_crash.wav")
#@onready var color_rect: ColorRect = $"../../LavaAnim/ColorRect"
@onready var collision_shape_2d: CollisionShape2D = $"../../LavaAnim/Area2D/CollisionShape2D"
@onready var lava_anim: Node2D = $"../../LavaAnim"
@onready var glow: Node2D = $"../../LavaAnim/Right/Glow"
@onready var lava_top_hud: Sprite2D = $"../../HUD/LavaTopHUD"
@onready var lava_hud: AnimatedSprite2D = $"../../HUD/LavaHUD"

var lava_speed: float

func _player_triggered() -> void:
	Audio.play_1d_sound(INTRO_CASTLE_CRUSH_2, false, {volume = -3})
	var cam: PlayerCamera2D = Thunder._current_camera
	if !cam: return
	cam.shock_smooth(12, 12)

func start_moving() -> void:
	collision_shape_2d.set_deferred(&"disabled", false)
	var tw = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS).set_trans(Tween.TRANS_CUBIC).set_parallel()
	#tw.tween_property(color_rect, "size:x", 896, 3.0)
	#tw.tween_property(color_rect, "position:x", 0, 3.0)
	tw.tween_property(self, "lava_speed", 70, 0.5)
	tw.tween_property(glow, "scale:y", 1.0, 2.0)
	if Thunder._current_player:
		tw.tween_property(lava_top_hud, "modulate:a", 1.0, 1.6)
		tw.tween_property(lava_hud, "modulate:a", 1.0, 1.6)

func _physics_process(delta: float) -> void:
	if lava_speed <= 0: return
	var cam: PlayerCamera2D = Thunder._current_camera
	if cam:
		if cam.get_screen_center_position().x + 380 < lava_anim.global_position.x + 896:
			lava_speed = 0
			return
	if lava_anim.global_position.x > 9248:
		lava_speed = 0
		return
	lava_anim.position.x += lava_speed * delta
	lava_speed = minf(lava_speed + 7 * delta, 275)
	var player: Player = Thunder._current_player
	if is_instance_valid(player):
		lava_hud.position.y = lava_top_hud.position.y - ((lava_anim.global_position.x + 1400) - player.global_position.x) / 40

func warped() -> void:
	var tw = create_tween().set_parallel()
	tw.tween_property(lava_hud, "modulate:a", 0, 2)
	tw.tween_property(lava_top_hud, "modulate:a", 0, 2)
