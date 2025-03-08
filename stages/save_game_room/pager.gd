extends StaticBumpingBlock

func _physics_process(delta):
	super(delta)
	if !Thunder._current_player: return
	_animated_sprite_2d.animation = &"empty" if !active else &"default"


func got_bumped(by_player: bool = false) -> void:
	if _triggered: return
	if !by_player: return
	var pl := Thunder._current_player
	if pl && pl.warp != Player.Warp.NONE: return
	bump(false)
