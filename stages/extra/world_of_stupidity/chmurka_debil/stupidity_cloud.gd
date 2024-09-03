extends AnimatedSprite2D

const TONGUE = preload("res://stages/extra/world_of_stupidity/chmurka_debil/tongue.tscn")
const STUPIDY_STAGE = preload("res://stages/extra/world_of_stupidity/chmurka_debil/stupidy STAGE.wav")

@export var trigger_radius: float = 100
@export var precise_radius_area: NodePath

@onready var radius_area: Area2D = get_node_or_null(precise_radius_area)
var _triggered: bool

func _ready() -> void:
	if radius_area:
		radius_area.body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	var pl: Player = Thunder._current_player
	if !pl: return
	
	if !radius_area && pl.global_position.distance_squared_to(global_position) <= trigger_radius ** 2:
		if !_triggered:
			trigger()
			_triggered = true
	else:
		_triggered = false


func trigger() -> void:
	Audio.play_sound(STUPIDY_STAGE, self, true, { ignore_pause = true })
	self_modulate.a = 1.0
	var tongue = TONGUE.instantiate()
	tongue.position = Vector2(38, 61)
	add_child.call_deferred(tongue)
	var tw = tongue.create_tween().set_trans(Tween.TRANS_CUBIC).set_loops(3).set_process_mode(Tween.TWEEN_PROCESS_IDLE)
	tw.tween_property(tongue, "rotation_degrees", -16, 0.08).set_ease(Tween.EASE_OUT)
	tw.tween_property(tongue, "rotation_degrees", 16, 0.16).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(tongue, "rotation_degrees", 0, 0.08).set_ease(Tween.EASE_IN)
	tw.finished.connect(func():
		var tw2 = tongue.create_tween()
		tw2.tween_property(tongue, "modulate:a", 0.0, 0.125)
		tw2.tween_callback(tongue.queue_free)
	)


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		trigger()
