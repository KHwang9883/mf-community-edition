extends Sprite2D

@onready var initial_pos: Vector2 = position
@export var multiplicator: float = 5
@export var speed: float = 300
var counter: float

func _physics_process(delta: float) -> void:
	counter += speed * delta
	position = initial_pos + Vector2(0, sin(deg_to_rad(counter)) * multiplicator)


const SUNKLASS = preload("res://gfx/fancy_graphics/sunklass.png")
const BOBAS_MARIO_JUMP = preload("res://stages/cutscenes/ending/part_3/sounds/bobas_mario_jump.wav")

@export var tries: int = 60
var progress: int = 0

@onready var area_2d: Area2D = $Area2D

func body_entered() -> void:
	if !is_visible_in_tree():
		return
	if progress == -1: return
	progress += 1
	
	if progress >= tries:
		texture = SUNKLASS
		Audio.play_sound(BOBAS_MARIO_JUMP, self, true, {volume = -6})
		progress = -1
		
		#var life: Node2D = LIFE_MUSHROOM.instantiate()
		#life.position = global_position + Vector2(0, 32)
		#Scenes.current_scene.add_child.call_deferred(life)
		#life.add_to_group(&"_secret_cloud_result")
		#life.z_index = -6
		#if "appear_visible" in life:
		#	life.appear_visible = 1
