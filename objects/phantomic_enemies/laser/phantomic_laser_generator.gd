extends AnimatableBody2D

const LASER: PackedScene = preload("./phantomic_laser.tscn")

@export_category("Phantomic Laser Generator")
@export_group("Physics")
@export var speed: float
@export var moving_range: Array[float] = [-64, 64]
@export_group("Laser")
@export var start_delay: float = 2
@export var interval: float = 3
@export var duration: float = 4

var tween: Tween
var tween_light: Tween

var laser: Node2D

var call_play: Callable = func() -> void:
	sound.play()

@onready var posx: float = global_transform.affine_inverse().basis_xform(global_position).x

@onready var pos_laser: Marker2D = $PosLaser
@onready var light: PointLight2D = $PosLaser/Light
@onready var particles: GPUParticles2D = $PosLaser/Particles
@onready var sound: AudioStreamPlayer2D = $Sound
@onready var visible_on_screen_enabler_2d: VisibleOnScreenEnabler2D = $VisibleOnScreenEnabler2D


func _ready() -> void:
	# Laser generation
	await get_tree().create_timer(start_delay, false, true).timeout
	tween = create_tween().set_loops()
	tween.tween_callback(_laser_on)
	tween.tween_interval(duration)
	tween.tween_callback(_laser_off)
	tween.tween_interval(interval)


func _physics_process(delta: float) -> void:
	# Movement
	global_position += Vector2.RIGHT.rotated(global_rotation) * speed * delta
	var px: float = global_transform.affine_inverse().basis_xform(global_position).x
	if px > posx + moving_range[1]:
		speed *= -1
		global_position += Vector2.LEFT.rotated(global_rotation) * abs(px - (posx + moving_range[1]))
	elif px < posx + moving_range[0]:
		speed *= -1
		global_position += Vector2.RIGHT.rotated(global_rotation) * abs(px - (posx + moving_range[0]))


func _laser_on() -> void:
	_play_sound()
	visible_on_screen_enabler_2d.enable_node_path = ^"."
	
	pos_laser.visible = true
	
	laser = LASER.instantiate()
	laser.position = pos_laser.position + Vector2.UP
	add_child(laser)
	move_child(laser, pos_laser.get_index() - 1)
	
	light.visible = true
	if !tween_light:
		tween_light = create_tween().set_loops()
		tween_light.tween_property(light, "scale", Vector2.ONE * 1.2, 0.1)
		tween_light.tween_property(light, "scale", Vector2.ONE, 0.1)
	
	particles.emitting = true


func _laser_off() -> void:
	_stop_sound()
	
	if tween_light:
		tween_light.kill()
		tween_light = null
	
	if is_instance_valid(laser):
		laser.queue_free()
	
	particles.emitting = false
	
	light.visible = false
	await get_tree().create_timer(1, false, true).timeout
	pos_laser.visible = false
	
	visible_on_screen_enabler_2d.enable_node_path = ^".."


func _play_sound() -> void:
	if !sound.finished.is_connected(call_play):
		sound.finished.connect(call_play)
	call_play.call()


func _stop_sound() -> void:
	if sound.finished.is_connected(call_play):
		sound.finished.disconnect(call_play)
	sound.stop()
