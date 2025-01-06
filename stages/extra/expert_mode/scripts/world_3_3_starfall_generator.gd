extends Node2D

const DAMAGING_STAR = preload("res://stages/extra/expert_mode/objects/damaging_star/damaging_star.tscn")

@export var active_min_pos: float = 350
@export var active_max_pos: float = 8384

var player: Player
var tw: Tween
var pl_pos: Vector2
var phase: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = Thunder._current_player
	tw = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS).set_loops()
	tw.tween_interval(0.6)
	tw.tween_callback(spawn_star)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if is_instance_valid(player):
		pl_pos = player.global_position
	var cannot_run: bool = pl_pos.x < active_min_pos || pl_pos.x > active_max_pos
	if !tw: return
	if cannot_run:
		tw.pause()
	elif !tw.is_running():
		tw.play()


func spawn_star() -> void:
	var starinst = DAMAGING_STAR.instantiate()
	var rand_x: float
	if phase:
		rand_x = pl_pos.x + randf_range(0, 352)
	else:
		rand_x = pl_pos.x + randf_range(-216, 64)
	starinst.position = Vector2(rand_x, -16)
	phase = !phase
	Scenes.current_scene.add_child(starinst)
