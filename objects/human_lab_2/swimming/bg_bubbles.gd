class_name BubbleGenerator extends Marker2D

const BUBBLE_BG = preload("res://engine/objects/effects/bubble/bubble.tscn")

@export_range(0.0,10.0,0.001, "or_greater", "hide_slider", "suffix:s")
var delay: float = 1.0
@export var debug_draw: bool

var _timer: Timer = Timer.new()

func _ready() -> void:
	add_child(_timer)
	_timer.one_shot = false
	_timer.timeout.connect(_spawn_bubble)
	_timer.start(delay)
	
var prev_pos: Vector2

func _physics_process(delta: float) -> void:
	if !Thunder.view.is_getting_closer(self, 128):
		return


func _spawn_bubble() -> void:
	var bubble = BUBBLE_BG.instantiate()
	bubble.z_index = z_index
	bubble.top_level = true
	bubble.global_position = global_position
	add_child(bubble)

func _draw() -> void:
	if !debug_draw: return
	var li := z_index 
	z_index = 1000
	draw_circle(Vector2.ZERO, 3, Color.RED)
	z_index = li