extends StaticBumpingBlock

func _physics_process(delta):
	super(delta)
	if !Thunder._current_player: return
	_animated_sprite_2d.animation = &"empty" if !active else &"default"


func got_bumped(by: Node2D) -> void:
	if _triggered: return
	if !by is Player: return
	if by.warp != Player.Warp.NONE: return
	bump(false)
