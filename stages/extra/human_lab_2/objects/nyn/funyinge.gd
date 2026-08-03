extends Node2D

const NYN = preload("res://stages/extra/human_lab_2/objects/nyn/nyn.ogg")
const GLASS_DESTROYED = preload("res://stages/extra/human_lab_2/objects/nyn/glass_destroyed.ogg")
const SND_LIGHTS_ON = preload("res://stages/extra/human_lab_2/objects/nyn/snd_lights_on.ogg")
const FALL = preload("res://engine/objects/enemies/spike_ceiling/sfx/fall.wav")

@onready var nyn_sign: Sprite2D = $"../NynSign"
@onready var nyn_container: Sprite2D = $"../NynContainer"
@onready var wrecked: StaticBody2D = $"../wrecked"
@onready var glass_shard_l: Sprite2D = $"../wrecked/GlassShardL"
@onready var glass_shard_l2: Sprite2D = $"../wrecked/GlassShardL2"
@onready var glass_shard_r: Sprite2D = $"../wrecked/GlassShardR"
@onready var glass_shard_r2: Sprite2D = $"../wrecked/GlassShardR2"
@onready var shattered_container: Sprite2D = $"../ShatteredContainer"

var init_timer: float
var triggered: bool
var sign_speed: float
var nyn_speed: float = -350
var shard_speeds := PackedVector2Array([
	Vector2(0, -312.5).rotated(deg_to_rad(-22.5)),
	Vector2(0, -312.5).rotated(deg_to_rad(-45)),
	Vector2(0, -312.5).rotated(deg_to_rad(22.5)),
	Vector2(0, -312.5).rotated(deg_to_rad(45)),
])

func _on_area_2d_3_player_enter() -> void:
	init_timer = 0.01


func _on_area_2d_3_player_exit() -> void:
	init_timer = 0.0


func _physics_process(delta: float) -> void:
	if init_timer > 0.0 && !triggered:
		init_timer += delta
		if init_timer > 15:
			triggered = true
			trigger()
	if triggered:
		sign_speed += delta * 12
		nyn_sign.position.y += sign_speed * delta * 50
		nyn_sign.rotation_degrees -= delta * 45
		shattered_container.rotation_degrees -= delta * 45
		shattered_container.position.y += sign_speed * delta * 50
		nyn_speed += delta * 500
		scale += Vector2.ONE * delta / 1.5
		position.y += nyn_speed * delta
		glass_shard_l.position += shard_speeds[0] * delta
		glass_shard_l2.position += shard_speeds[1] * delta
		glass_shard_r.position += shard_speeds[2] * delta
		glass_shard_r2.position += shard_speeds[3] * delta
		for i: int in shard_speeds.size():
			shard_speeds[i].y += delta * 20 * 50
		glass_shard_l.rotation -= TAU * delta
		glass_shard_l2.rotation -= TAU * delta * 2
		glass_shard_r.rotation += TAU * delta
		glass_shard_r2.rotation += TAU * delta * 2
		
		if position.y > 1000:
			queue_free()
			triggered = false

func trigger() -> void:
	Audio.play_1d_sound(NYN, false)
	Audio.play_1d_sound(GLASS_DESTROYED, false)
	Audio.play_1d_sound(SND_LIGHTS_ON, false)
	Audio.play_1d_sound(FALL, false)
	nyn_container.queue_free()
	wrecked.show()
	Thunder._current_camera.shock_smooth(16, 8)
	glass_shard_l.show()
	glass_shard_l2.show()
	glass_shard_r.show()
	glass_shard_r2.show()
	shattered_container.show()
	show()
