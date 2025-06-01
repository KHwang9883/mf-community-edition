extends Node

@onready var platform_path_tank_floor: PathFollow2D = $"../Path2D/PathFollow2D/PlatformPathTankFloor"
@onready var parallax_2d: Parallax2D = $"../floor/Parallax2D"

var speed: float = 0
var speed_enabled: bool

func _ready() -> void:
	await get_tree().create_timer(2, false, true, false).timeout
	speed_enabled = true

func _physics_process(delta: float) -> void:
	if !speed_enabled: return
	var pl = Thunder._current_player
	if pl:
		speed = min(speed + 30 * delta, 200)
	else:
		speed = max(speed - 300 * delta, 0)
	
	parallax_2d.autoscroll.x = speed
	platform_path_tank_floor.position.x += speed * delta
	
