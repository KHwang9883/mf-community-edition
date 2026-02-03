extends Projectile

@export var angle_precision_deg: float = 11.25
@export var remove_offscreen_after: float = 1.0

func _ready() -> void:
	offscreen_handler(remove_offscreen_after)
	super()
	var pl: Player = Thunder._current_player
	if !pl: return
	
	look_at(pl.global_position)
	var ANGLE: float = angle_precision_deg * (PI / 180.0)
	global_rotation = ANGLE * roundf(global_rotation / ANGLE)
	speed = speed.rotated(global_rotation)


func _on_level_end() -> void:
	if !Thunder.view.is_getting_closer(self, 32):
		if Thunder.view.is_getting_closer(self, 2048):
			queue_free()
		return
	Data.add_score(100)
	ScoreText.new(str(100), self)
	queue_free()
