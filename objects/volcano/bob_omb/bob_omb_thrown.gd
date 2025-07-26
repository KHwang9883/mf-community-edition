extends "res://objects/volcano/bob_omb/bob_omb.gd"

@export var rotation_speed: float = 22.5
@export var free_offscreen: bool = false

@onready var solid_checker: Area2D = $SolidChecker
@onready var col: CollisionShape2D = $Collision
@onready var visible_on_screen_enabler_2d: VisibleOnScreenEnabler2D = $VisibleOnScreenEnabler2D

var collision_enabled: bool = false
var _is_ready: bool = false

func _ready() -> void:
	if free_offscreen:
		visible_on_screen_enabler_2d.screen_exited.connect(queue_free)
	for i in 2:
		await get_tree().physics_frame
	_is_ready = true

func _physics_process(delta: float) -> void:
	super(delta)
	get_node(sprite).rotation_degrees += rotation_speed * Thunder.get_delta(delta)
	if !_is_ready: return
	
	if !collision_enabled:
		if solid_checker.get_overlapping_bodies().size() == 0:
			collision_enabled = true
			col.set_deferred(&"disabled", false)
		elif speed.y > 250:
			_explode()
			return
	
	if collision_enabled && (is_on_floor() || is_on_wall()):
		_explode()
