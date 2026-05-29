extends StaticBumpingBlock

func got_bumped(by_player: bool = false) -> void:
	if _triggered: return
	if !by_player: return
	call_bump()


func call_bump() -> void:
	bump(true)
	_animated_sprite_2d.animation = &"empty"
	Scenes.current_scene.get_node("U-XController").add_question_mark_score()
