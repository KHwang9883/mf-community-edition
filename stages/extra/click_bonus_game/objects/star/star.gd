extends Area2D

const STAR_FLYING = preload("res://stages/extra/click_bonus_game/objects/star_flying/star_flying.tscn")

@export var sounds: Array[AudioStream] = []
@export var bouncing_ball: bool = false

var counter: float = 0

var velocity = Vector2(100, 0)
var moving = 0
var timer = Timer.new()

@onready var bonus_star: Sprite2D = $BonusStar
@onready var star_finder_cursor: Sprite2D = Scenes.current_scene.get_node("Heads-Up Display/StarFinderCursor")

func _ready() -> void:
	velocity = velocity.rotated(deg_to_rad(randi_range(0, 360)))

func activate() -> void:
	Audio.play_1d_sound(sounds.pick_random())
	
	var flying = STAR_FLYING.instantiate()
	flying.angle = randf_range(0, 360)
	Scenes.current_scene.add_child(flying)
	flying.global_transform = global_transform
	
	Scenes.current_scene.h_box_container._star_collected()
	queue_free()


func _process(delta: float) -> void:
	if bouncing_ball:
		counter += delta * 25
		bonus_star.offset = Vector2(0, sin(counter) * 3).rotated(-rotation)

func _physics_process(delta: float) -> void:
	if moving:
		global_position += velocity * delta
		Thunder.view.cam_border()
		if global_position.x + (bonus_star.texture.get_width() * scale.x) / 2 > Thunder.view.border.end.x || global_position.x - (bonus_star.texture.get_width() * scale.x) / 2 < Thunder.view.border.position.x:
			velocity.x = -velocity.x
		if global_position.y + (bonus_star.texture.get_height() * scale.y) / 2 > Thunder.view.border.end.y || global_position.y - (bonus_star.texture.get_height() * scale.y) / 2 < Thunder.view.border.position.y:
			velocity.y = -velocity.y

func ball_stop() -> void:
	moving -= 1

func ball_entered(area: Area2D) -> void:
	if !area.is_in_group(&"mouse_cursor"): return
	if !bouncing_ball: return
	moving += 1
	await get_tree().create_timer(4, false).timeout
	ball_stop()
