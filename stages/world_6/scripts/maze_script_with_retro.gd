extends "res://engine/objects/detectors/maze_script.gd"

@export var retro_to_dir: int = -1

func entered_and_retro() -> void:
	var cam: PlayerCamera2D = Thunder._current_camera
	if !cam: return
	if !cam.is_retro_scroll():
		entered()
		return
	
	if retro_to_dir == cam.retro_scroll_direction:
		return
	var _sfx = CharacterManager.get_sound_replace(INCORRECT, INCORRECT, "menu_failure", false)
	Audio.play_1d_sound(_sfx, false)
	cam.switch_to_direction(retro_to_dir)
