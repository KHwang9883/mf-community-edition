extends StaticBumpingBlock

func got_bumped(by_player: bool = false, trigger_hit_attacker: bool = true) -> void:
	#if _triggered: return
	if !by_player: return
	call_bump(trigger_hit_attacker)


func call_bump(trigger_hit_attacker: bool = true) -> void:
	bump(true, 0, trigger_hit_attacker)
