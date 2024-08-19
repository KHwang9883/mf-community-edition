extends "res://engine/components/hud/hud.gd"

var warning_played: bool

func _ready() -> void:
	time_counter.floor_value = true
	
	Thunder._current_hud = self
	while !Thunder._current_player:
		await get_tree().physics_frame
	
	var tw = time_text.create_tween().set_loops()
	tw.tween_property(time_text, "scale", Vector2.ONE / 2.0, 0.16)
	tw.tween_property(time_text, "scale", Vector2.ONE, 0.16)
	var player = Thunder._current_player
	player.died.connect(func():
		tw.stop()
		time_text.scale = Vector2.ONE
	)

func _physics_process(delta: float) -> void:
	var player: Player = Thunder._current_player
	if !player: return
	if player.completed:
		return
	if Data.values.time > 0:
		Data.values.time -= 111 * 50 * delta
	
	if Data.values.time > 18_000 && warning_played:
		warning_played = false
	if Data.values.time < 10_000 && !warning_played:
		warning_played = true
		timer_hurry()
	if Data.values.time <= 0:
		Data.values.time = 0
		player.die()


func _on_mario_starman_attacked() -> void:
	Data.values.time += 2000

func time_countdown(_first_time: bool = true) -> void:
	if Data.values.time > 110:
		Data.values.time -= 100
		Data.values.score += 1000
	if Data.values.time > 1100:
		Data.values.time -= 1000
		Data.values.score += 10000
	super(_first_time)
	if Data.values.time < 0.0:
		Data.values.time = 0
