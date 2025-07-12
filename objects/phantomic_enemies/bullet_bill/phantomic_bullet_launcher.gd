extends AnimatableBody2D

@export_category("BulletBillLauncher")
@export var rotation_ratio: float = 0.01
@export_group("Bullet")
@export var bullet_bill: InstanceNode2D
@export var explosion: PackedScene = preload("res://engine/objects/effects/explosion/explosion.tscn")
@export var bullet_speed: float = 162.5
@export_group("Shooting")
@export var stop_shooting_radius: float = 80
@export var first_shooting_delay: float = 0.5
@export var shooting_delay_min: float = 5
@export var shooting_delay_max: float = 8
@export_group("Sound")
@export var shooting_sound: AudioStream = preload("res://engine/objects/enemies/bullet_bill/bill/sounds/missile_bullet.ogg")
@export var sound_pitch_min: float = 1.0
@export var sound_pitch_max: float = 1.2

@onready var launcher: Sprite2D = $Launcher
@onready var pos_bullet: Marker2D = $Launcher/PosBullet
@onready var interval: Timer = $Interval


func _ready() -> void:
	interval.start(first_shooting_delay)
	
	var player: Player = Thunder._current_player
	if !player: return
	launcher.global_rotation = launcher.global_position.angle_to_point(player.global_position)


func _physics_process(delta: float) -> void:
	var player: Player = Thunder._current_player
	if !player: return
	
	var look_at_pos: float = launcher.global_position.angle_to_point(player.global_position)
	launcher.global_rotation = lerp_angle(launcher.global_rotation, look_at_pos, rotation_ratio)
	if launcher.rotation > PI/2 || launcher.rotation < -PI/2:
		launcher.flip_v = true
	else:
		launcher.flip_v = false


func _on_bullet_launched() -> void:
	var player: Player = Thunder._current_player
	if !player:
		interval.start(0.1)
		return
	
	if player.global_position.distance_squared_to(global_position) <= stop_shooting_radius ** 2:
		interval.start(0.1)
		return
	
	var dir: int = Thunder.Math.look_at(pos_bullet.global_position, player.global_position, pos_bullet.global_transform)
	Audio.play_sound(
		shooting_sound, pos_bullet, false, {
			"pitch": randf_range(sound_pitch_min, sound_pitch_max)
		}
	)
	var bulbil := NodeCreator.prepare_ins_2d(bullet_bill, self).create_2d().call_method(
		func(bul: Node2D) -> void:
			bul.global_transform = Transform2D(0, launcher.global_position)
			bul.sprite_node.global_rotation = launcher.global_rotation
			if bul is GeneralMovementBody2D:
				bul.look_at_player = false
				bul.dir = dir
				bul.vel_set(Vector2.RIGHT.rotated(launcher.global_rotation) * bullet_speed * dir)
	)
	var eff := NodeCreator.prepare_2d(explosion, pos_bullet).create_2d()
	eff.get_node().global_position = bulbil.get_node().global_position
	interval.start(randf_range(shooting_delay_min, shooting_delay_max))


func _on_screen_entered() -> void:
	interval.paused = false


func _on_screen_exited() -> void:
	interval.paused = true
