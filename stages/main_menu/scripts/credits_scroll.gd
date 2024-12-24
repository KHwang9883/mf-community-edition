extends Node2D

@export var speed: float = 25
@export var repeat_size: float = 1950

var _scroll_delay: float
var _target_pos: float
var _old_modulo: int

func _ready() -> void:
	Thunder._connect(SettingsManager.mouse_pressed, func(index: MouseButton):
		match index:
			MOUSE_BUTTON_WHEEL_DOWN:
				_scroll_delay = 1.0
				_target_pos -= 40
			MOUSE_BUTTON_WHEEL_UP:
				_scroll_delay = 1.0
				_target_pos += 40
	)

func _physics_process(delta: float) -> void:
	if position.y < -repeat_size:
		position.y += repeat_size
		_target_pos = position.y
		reset_physics_interpolation()
	elif position.y > 0.0:
		position.y -= repeat_size
		_target_pos = position.y
		reset_physics_interpolation()
	position.y = lerpf(position.y, _target_pos, 30.0 * delta)
	
	if _scroll_delay > 0.0:
		_scroll_delay -= delta
		return
	
	_target_pos -= speed * delta


func _input(event: InputEvent) -> void:
	if !event.is_pressed(): return
	if event.is_action(&"ui_up"):
		_scroll_delay = 1.0
		_target_pos += 40
	elif event.is_action(&"ui_down"):
		_scroll_delay = 1.0
		_target_pos -= 40
	
