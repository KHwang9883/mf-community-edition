@tool
extends Control

const PODOBOO: PackedScene = preload("./phantomic_podoboo.tscn")

@export_category("Phantomic Podoboo Generator")
@export_group("Generating")
@export var interval: float = 2
@export var interval_random: float = 3
@export_group("Podoboo Physics")
@export var velocity_min: Vector2 = Vector2(-200, -800)
@export var velocity_max: Vector2 = Vector2(200, -500)

var dir: int = 1

@onready var timer_interval: Timer = $Interval


func _draw() -> void:
	if !Engine.is_editor_hint():
		return
	draw_set_transform(-position, -rotation, Vector2.ONE/scale)
	draw_rect(get_rect(), Color.FIREBRICK, false, 4)


func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()
		return
	
	var player: Player = Thunder._current_player
	if !player || !get_rect().has_point(player.global_position):
		return
	
	if timer_interval.is_stopped():
		timer_interval.start(interval + randf_range(0, interval_random))


func _on_interval_timeout() -> void:
	var par: Node2D = get_parent()
	
	var ran: float = randf_range(0, 96)
	var pos := Vector2(Thunder._current_player.global_position.x + (ran + 64) * dir, get_viewport_transform().affine_inverse().get_origin().y + get_viewport_rect().size.y + 64)
	
	NodeCreator.prepare_2d(PODOBOO, get_parent() as Node2D).call_method(
		func(pdb: Node2D) -> void:
			pdb.velocity = Vector2(
				randf_range(velocity_min.x, velocity_max.x),
				randf_range(velocity_min.y, velocity_max.y)
			)
			pdb.set_deferred(&"global_position", pos)
			pdb.reparent.call_deferred(par)
	).create_2d()
