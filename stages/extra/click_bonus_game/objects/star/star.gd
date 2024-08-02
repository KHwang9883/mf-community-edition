extends Area2D

@onready var bonus_star = $BonusStar
@onready var star_finder_cursor = $"../Heads-Up Display/StarFinderCursor"
const STAR_FLYING = preload("res://stages/extra/click_bonus_game/objects/star_flying/star_flying.tscn")
@export var sounds: Array[AudioStream] = []
@export var bouncing_ball: bool = false
var _can_activate: bool = false
var counter: float = 0
signal collected

var velocity = Vector2(100, 0)
var moving = 0
var timer = Timer.new()

func _ready() -> void:
	velocity = velocity.rotated(deg_to_rad(randi_range(0, 360)))

func activate() -> void:
	Audio.play_1d_sound(sounds.pick_random())
	
	var flying = STAR_FLYING.instantiate()
	flying.transform = transform
	flying.angle = randf_range(0, 360)
	Scenes.current_scene.add_child(flying)
	
	collected.emit()
	queue_free()
	
	await get_tree().physics_frame
	star_finder_cursor.remove_hover()


func _process(delta: float) -> void:
	if bouncing_ball:
		counter += delta * 25
		bonus_star.position.y = sin(counter) * 3

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

func ball_entered() -> void:
	if !bouncing_ball: return
	moving += 1
	await get_tree().create_timer(4, false).timeout
	ball_stop()

func _on_mouse_entered():
	_can_activate = true
	star_finder_cursor.add_hover()

func _on_mouse_exited():
	_can_activate = false
	star_finder_cursor.remove_hover()

func _input(event):
	if event is InputEventMouseButton && event.is_pressed() && event.button_index == 1 && _can_activate:
		activate()
