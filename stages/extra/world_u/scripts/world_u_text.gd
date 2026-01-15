extends "res://engine/scenes/map/scripts/world_text.gd"

@onready var area_2d: Area2D = $Area2D
var activated: bool

func _ready() -> void:
	super()
	area_2d.input_event.connect(_on_area_2d_input_event)


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if activated: return
	
	if event is InputEventMouseButton && event.button_index == 1 && event.is_pressed():
		marker_pos.y = 580
		activated = true

func _physics_process(delta: float) -> void:
	delta = Thunder.get_delta(delta)
	position.y += speed * delta
	speed += 0.4 * delta
	
	if activated:
		if global_position.y >= marker_pos.y - texture.get_height() / 2.0 && speed > 0:
			speed *= -1
			if speed < -6:
				speed += 3
			elif global_position.y > 524:
				activated = false
				speed *= -1
				position.y = -56
				reset_physics_interpolation()
				marker_pos.y = 80
		return
	
	if global_position.y >= marker_pos.y - texture.get_height() / 2.0 && speed > 0:
		speed *= -1
		if speed < -3:
			speed /= 2
			speed -= 1
