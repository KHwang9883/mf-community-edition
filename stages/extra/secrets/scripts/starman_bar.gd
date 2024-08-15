extends TextureProgressBar

func _physics_process(delta: float) -> void:
	var player: Player = Thunder._current_player
	if !player: return
	
	value = player.timer_starman.time_left
