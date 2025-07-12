extends AnimatableBody2D

@export var range_to_show: float = 128.0
@export var not_showing_y_pos: float = 512

var player: Player

@onready var y_pos: float = global_position.y
@onready var sprite = $Sprite
@onready var visible_screen_enabler: VisibleOnScreenEnabler2D = $VisibleOnScreenEnabler2D


func _ready() -> void:
	global_position.y = not_showing_y_pos
	visible_screen_enabler.rect = Rect2(-64, -640, 128, 672)


func _physics_process(delta: float) -> void:
	player = Thunder._current_player
	
	var mario_near: bool
	if player: mario_near = player && (player.global_position.x > global_position.x - range_to_show && player.global_position.x < global_position.x + range_to_show)
	
	var speed: float = 12 * delta
	if mario_near && !is_equal_approx(global_position.y, y_pos):
		global_position.y = lerpf(global_position.y, y_pos, speed)
	elif !mario_near && !is_equal_approx(global_position.y, not_showing_y_pos):
		global_position.y = lerpf(global_position.y, not_showing_y_pos, speed)
