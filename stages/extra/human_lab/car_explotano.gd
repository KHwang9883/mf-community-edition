extends "res://stages/extra/human_lab/scripts/human_lab_sounds.gd"

const EXPLODE = preload("res://sfx/explode.wav")

var waiter: float
var veloc: float
var finished: bool
@onready var animated_sprite_2d: AnimatedSprite2D = $"../Clones/AnimatedSprite2D"

func _physics_process(delta: float) -> void:
	super(delta)
	if finished: return
	if veloc > 1:
		veloc += delta * 50
		animated_sprite_2d.position.x += veloc * delta
	
	if animated_sprite_2d.global_position.x > 2408:
		#animated_sprite_2d.visible = false
		Audio.play_sound(EXPLODE, animated_sprite_2d, false)
		animated_sprite_2d.animation = "explode"
		animated_sprite_2d.play(&"explode")
		finished = true
		await get_tree().create_timer(1.5, false, false).timeout
		queue_free()
		
	if !is_inside: return
	if waiter < 0: return
	waiter += delta
	if waiter > 30: #30
		veloc = 20
		waiter = -1
	

func _on_player_entered() -> void:
	is_inside = true
	waiter = 0


func _on_player_exited() -> void:
	is_inside = false
	waiter = -1
