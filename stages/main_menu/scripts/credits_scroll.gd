extends Node2D

@export var speed: float = 25
@export var repeat_size: float = 1950

var _scroll_force: float
var _target_pos: float

func _ready() -> void:
	Thunder._connect(SettingsManager.mouse_pressed, func(index: MouseButton):
		match index:
			MOUSE_BUTTON_WHEEL_DOWN:
				_target_pos -= 40
			MOUSE_BUTTON_WHEEL_UP:
				_target_pos += 40
	)

func _physics_process(delta: float) -> void:
	_scroll_force = Input.get_axis(&"ui_down", &"ui_up") * 300
	
	if position.y < -repeat_size:
		position.y += repeat_size
		_target_pos = position.y
		reset_physics_interpolation()
	elif position.y > 0.0:
		position.y -= repeat_size
		_target_pos = position.y
		reset_physics_interpolation()
	
	_target_pos += _scroll_force * delta
	
	position.y = lerpf(position.y, _target_pos, 30.0 * delta)
	
	if _scroll_force:
		_scroll_force = 0.0
	else:
		_target_pos -= speed * delta
