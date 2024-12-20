extends CanvasItem

@onready var player = Thunder._current_player
@onready var marker = $Marker2D

func _process(delta: float) -> void:
	if !player:
		player = Thunder._current_player
		return
	#visible = player.global_position.distance_squared_to(marker.global_position) <= 112 ** 2
