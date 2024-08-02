extends Sprite2D

const ARR = preload("res://engine/objects/enemies/lakitus/sounds/lakitu_myu.ogg")
@onready var timer = $Timer
const CURSOR_EFFECT = preload("res://stages/extra/click_bonus_game/objects/cursor_effect/cursor_effect.tscn")
const DIE = preload("res://stages/extra/click_bonus_game/sfx/die.wav")
@onready var gpu_particles_2d = $GPUParticles2D
@onready var gpu_particles_2d_2 = $GPUParticles2D2

var hover_count: int = 0

func _ready() -> void:
	timer.timeout.connect(_create_effect)


func _input(event) -> void:
	if event is InputEventMouseMotion:
		global_position = event.global_position
	
	if event is InputEventMouseButton && event.button_index == 1 && event.is_pressed():
		if !hover_count:
			gpu_particles_2d.restart()
			Audio.play_1d_sound(DIE)
		else:
			gpu_particles_2d_2.restart()
			Audio.play_1d_sound(ARR)


func _create_effect() -> void:
	var eff = CURSOR_EFFECT.instantiate()
	eff.transform = transform
	owner.add_child(eff)


func add_hover() -> void:
	hover_count += 1


func remove_hover() -> void:
	hover_count -= 1
