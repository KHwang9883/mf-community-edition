extends Node2D

const DAMAGING_STAR = preload("res://stages/extra/expert_mode/objects/damaging_star/damaging_star.tscn")

signal completed_with_star_rain

@export var is_active: bool = true
@export var spawn_delay: float = 0.6

var player: Player
var _has_setup: bool
var tw: Tween
var pl_pos: Vector2
var phase: bool

#@onready var question_block_star: AnimatableBody2D = $"../QuestionBlock2"

func _ready() -> void:
	player = Thunder._current_player
	if !is_instance_valid(player): return
	pl_pos = player.global_position
	
#	if KevinGlobal.activated || true:
#		question_block_star.bumped.connect(func():
#			spawn_delay = 0.3
#			if tw:
#				tw.kill()
#			setup_tween()
#			Thunder._connect(Scenes.current_scene.level_completed, _on_level_completed, CONNECT_ONE_SHOT)
#		)

func _on_level_completed() -> void:
	completed_with_star_rain.emit()

func setup_tween() -> void:
	tw = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS).set_loops()
	tw.tween_interval(spawn_delay)
	tw.tween_callback(spawn_star)


func _physics_process(delta: float) -> void:
	if is_instance_valid(player):
		if !_has_setup && pl_pos.distance_squared_to(player.global_position) > 4:
			_has_setup = true
			setup_tween()
		if player.completed && tw:
			return tw.kill()
		if !_has_setup:
			return
		pl_pos = player.global_position
	
	if !tw: return
	if !is_active:
		tw.pause()
	elif !tw.is_running():
		tw.play()


func spawn_star() -> void:
	if Data.values.stopwatch > 0: return
	var cam: Camera2D = Thunder._current_camera
	if !cam:
		return
	var rand_x: float
	if phase:
		rand_x = pl_pos.x + randf_range(96, 352)
	else:
		rand_x = pl_pos.x + randf_range(-96, 96)
	var y_pos: float = cam.get_screen_center_position().y - 256
	var starinst = DAMAGING_STAR.instantiate()
	starinst.position = Vector2(rand_x, y_pos)
	phase = !phase
	Scenes.current_scene.add_child(starinst)
