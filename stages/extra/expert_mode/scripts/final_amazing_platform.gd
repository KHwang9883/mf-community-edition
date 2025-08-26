extends StaticBumpingBlock

func got_bumped(by_player: bool = false) -> void:
	#if _triggered: return
	if !by_player: return
	call_bump()


func call_bump() -> void:
	bump(true)
