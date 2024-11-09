extends Sprite2D

var easer: bool = false
@export var is_black: bool = false
var state: int = 0
var counter: float = 1

var limits: Rect2i
var speed: float = 0.04
var function: Thunder.SmoothFunction = Thunder.SmoothFunction.EASE_IN_OUT

@onready var _tweak: bool = SettingsManager.get_tweak("enable_smooth_cam_transitions", true)

func _physics_process(delta: float) -> void:
	var player: Player = Thunder._current_player
	if !_tweak || (player && player.warp != player.Warp.NONE):
		modulate.a = 0.0 if is_black else 1.0
		counter = 1
		return
	
	if easer:
		counter += speed * Thunder.get_delta(delta)
		counter = clamp(counter, 0, 1)
	
	var eased_counter: float
	eased_counter = Thunder.Math.ease_in_out(counter)
	
	modulate.a = -eased_counter + 1 if is_black else eased_counter
	if counter == 1:
		easer = false

func _ready():
	if !is_black:
		modulate.a = 1
	await get_tree().physics_frame
	easer = false
	counter = 1

func ease_hide(): # lower
	if is_black: return
	easer = true
	is_black = true
	counter = 0

func ease_show(): # upper
	if !is_black: return
	easer = true
	is_black = false
	counter = 0
