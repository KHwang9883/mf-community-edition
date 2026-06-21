extends PathFollow2D

@export var speed: float = 60
@export var reverse: bool = false
@export var warp_objects_on_end: bool = true
@export var warping_edge_ignore_px: float = 6.0

@onready var curve: Curve2D
@onready var max_progress: float

func _ready() -> void:
	if warp_objects_on_end:
		return
	
	curve = (
		func() -> Curve2D:
			if !get_parent() is Path2D: return null
			return get_parent().curve
	).call()
	max_progress = (
		func() -> float:
			if !curve: return 0.0
			var max_length: float
			var current: float = progress_ratio
			progress_ratio = 1.0
			max_length = progress
			progress_ratio = current
			return max_length
	).call()

func _physics_process(delta: float) -> void:
	progress += speed * delta
	
	if reverse && (progress_ratio >= 1 || progress_ratio <= 0):
		speed = -speed
	
	if !warp_objects_on_end:
		if max_progress < warping_edge_ignore_px:
			return
		if progress < warping_edge_ignore_px || progress + warping_edge_ignore_px > max_progress:
			reset_physics_interpolation()
