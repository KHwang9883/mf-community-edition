extends Node2D

const SPINY_RED = preload("uid://c58i0gaq0il4o")
const RED_MUSHROOM = preload("uid://b71msw28e37a")

@onready var marker_2d: Marker2D = $Marker2D
@onready var marker_2d_2: Marker2D = $Marker2D2

var dispenced_item: bool
var dispence_delay: float
var disable_spawner: bool

func _physics_process(delta: float) -> void:
	if dispenced_item: return
	if !Thunder._current_player: return
	if Thunder._current_player.suit.type != PlayerSuit.Type.SMALL: return
	dispence_delay += delta
	if dispence_delay > 1.0:
		dispenced_item = true
		var mush = RED_MUSHROOM.instantiate()
		mush.position = Vector2(320, -15)
		mush.speed.x = 0
		Scenes.current_scene.add_child(mush)

func _on_timer_timeout() -> void:
	if !Thunder._current_player: return
	if disable_spawner: return
	var spiny = SPINY_RED.instantiate()
	if Thunder._current_player.global_position.x > 320:
		spiny.position = marker_2d.global_position
	else:
		spiny.position = marker_2d_2.global_position
	Scenes.current_scene.add_child(spiny)


func _on_bowser_health_changed(to: int) -> void:
	if to <= 0:
		disable_spawner = true
