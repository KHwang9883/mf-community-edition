@tool
extends Node2D

const LASER: PackedScene = preload("./phantomic_laser.tscn")

@export_category("Phantomic Laser Locker")
@export var locking_area: Area2D
@export var starting_delay: float = 0.3

var call_play: Callable = func() -> void:
	sound.play()

var laser: Line2D
var last_player_position: Vector2

@onready var light: PointLight2D = $Light
@onready var sound: AudioStreamPlayer2D = $Sound


func _ready() -> void:
	if Engine.is_editor_hint(): return
	
	locking_area.body_entered.connect(
		func(body: Node2D) -> void:
			var player: Player = Thunder._current_player
			if body != player:
				return
			
			last_player_position = player.global_position
			
			await get_tree().create_timer(starting_delay, false, true).timeout
			if !locking_area.overlaps_body(body) || laser:
				return
			
			light.visible = true
			laser = LASER.instantiate()
			laser.position = light.position
			laser.to_player = true
			add_child(laser)
			laser.global_rotation = light.global_position.angle_to_point(last_player_position) + PI/2
			_play_sound()
	)
	locking_area.body_exited.connect(
		func(body: Node2D) -> void:
			if body != Thunder._current_player || !is_instance_valid(laser):
				return
			laser.queue_free()
			laser = null
			light.visible = false
			_stop_sound()
	)


func _draw() -> void:
	if !Engine.is_editor_hint() || !locking_area: return
	draw_set_transform(Vector2.ZERO, -rotation, Vector2.ONE/scale)
	for i in locking_area.get_shape_owners():
		draw_line(Vector2.ZERO, locking_area.shape_owner_get_owner(i).polygon[0] - position, Color.RED, 4)


func _process(delta: float) -> void:
	if !Engine.is_editor_hint(): return
	queue_redraw()


func _play_sound() -> void:
	if !sound.finished.is_connected(call_play):
		sound.finished.connect(call_play)
	call_play.call()


func _stop_sound() -> void:
	if sound.finished.is_connected(call_play):
		sound.finished.disconnect(call_play)
	sound.stop()
