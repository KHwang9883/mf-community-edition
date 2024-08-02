extends Sprite2D

const LAKITU_MYU = preload("res://engine/objects/enemies/lakitus/sounds/lakitu_myu.ogg")
const CURSOR_EFFECT = preload("res://stages/extra/click_bonus_game/objects/cursor_effect/cursor_effect.tscn")
const DIE = preload("res://stages/extra/click_bonus_game/sfx/die.wav")

var hover_count: int = 0

@onready var timer = $Timer
@onready var gpu_particles_2d = $GPUParticles2D
@onready var gpu_particles_2d_2 = $GPUParticles2D2



func _ready() -> void:
	timer.timeout.connect(_create_effect)


func _input(event) -> void:
	if event is InputEventMouseMotion:
		global_position = event.global_position
	
	if !Scenes.current_scene.can_interact:
		return
	
	if event is InputEventMouseButton && event.button_index == 1 && event.is_pressed():
		if !hover_count:
			gpu_particles_2d.restart()
			Audio.play_1d_sound(DIE)
			Scenes.current_scene.tries._try_lost()
		else:
			gpu_particles_2d_2.restart()
			Audio.play_1d_sound(LAKITU_MYU)


func _create_effect() -> void:
	var eff = CURSOR_EFFECT.instantiate()
	eff.transform = transform
	owner.add_child(eff)


func add_hover() -> void:
	hover_count += 1


func remove_hover() -> void:
	hover_count -= 1
