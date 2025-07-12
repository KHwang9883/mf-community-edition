@tool
extends Area2D

@export_category("Gravity Area")
@export var new_gravity_direction: Vector2 = Vector2.DOWN:
	set(to):
		new_gravity_direction = to.normalized()


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	
	var player: Player = Thunder._current_player
	if !player: return
	
	if overlaps_body(player):
		player.global_rotation = lerp_angle(player.global_rotation, new_gravity_direction.angle() - PI/2, 0.2)
