extends AnimatedSprite2D

@export var speed: float = 8
@export var teleport_by: float = 736

@onready var init_pos = position.x

var disappearing: bool

func _physics_process(delta: float):
	var cam: Camera2D = Thunder._current_camera as Camera2D
	if !cam: return
	position.x -= speed * delta
	var cam_pos: float = cam.get_screen_center_position().x

	while position.x >= cam_pos + 320 + 32:
		position.x -= teleport_by
	while position.x < cam_pos - 320 - 32:
		position.x += teleport_by

	if disappearing:
		_disappear_process(delta)
	
func _disappear_process(delta: float) -> void:
	if modulate.a <= 0.01:
		queue_free()
		return
	modulate.a -= 0.5 * delta
