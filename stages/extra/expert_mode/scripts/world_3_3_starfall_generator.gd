extends Node2D

const DAMAGING_STAR = preload("res://stages/extra/expert_mode/objects/damaging_star/damaging_star.tscn")

signal completed_with_star_rain

@export var active_min_pos: float = 350
@export var active_max_pos: float = 8384
@export var checkp_min: float = 4150
@export var checkp_max: float = 4300
@export var spawn_delay: float = 0.6

var player: Player
var tw: Tween
var pl_pos: Vector2
var phase: bool

@onready var question_block_star: AnimatableBody2D = $"../QuestionBlock2"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = Thunder._current_player
	setup_tween()
	if KevinGlobal.activated || true:
		question_block_star.bumped.connect(func():
			spawn_delay = 0.3
			if tw:
				tw.kill()
			setup_tween()
			Thunder._connect(Scenes.current_scene.level_completed, _on_level_completed, CONNECT_ONE_SHOT)
		)

func _on_level_completed() -> void:
	completed_with_star_rain.emit()

func setup_tween() -> void:
	tw = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS).set_loops()
	tw.tween_interval(spawn_delay)
	tw.tween_callback(spawn_star)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if is_instance_valid(player):
		if player.completed && tw:
			return tw.kill()
		pl_pos = player.global_position
	
	var cannot_run: bool = pl_pos.x < active_min_pos || pl_pos.x > active_max_pos
	if pl_pos.x > checkp_min && pl_pos.x < checkp_max:
		cannot_run = true
	
	if !tw: return
	if cannot_run:
		tw.pause()
	elif !tw.is_running():
		tw.play()


func spawn_star() -> void:
	if Data.values.stopwatch > 0: return
	var starinst = DAMAGING_STAR.instantiate()
	var rand_x: float
	if phase:
		rand_x = pl_pos.x + randf_range(96, 352)
	else:
		rand_x = pl_pos.x + randf_range(-96, 96)
	starinst.position = Vector2(rand_x, -16)
	phase = !phase
	Scenes.current_scene.add_child(starinst)
