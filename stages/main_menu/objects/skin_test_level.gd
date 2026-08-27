@warning_ignore("missing_tool")
extends Stage2D

@export var enable_restart_in_pause: bool = true
@warning_ignore("unused_private_class_variable")
var _skin_test_level: bool = true

func _init() -> void:
	Data.values.time = -1
	Data.values.lives = 4
	Console.cv.item_display_shown = true


func _ready() -> void:
	Console.cv.item_display_shown = true
	Scenes.custom_scenes.pause.open_blocked = true
	super()

func _physics_process(delta: float) -> void:
	if !_is_stage_ready: return
	if Scenes.custom_scenes.pause.opened || Scenes.custom_scenes.game_over.opened:
		return
	if !Data.technical_values.get("main_menu_scene"): return
	if is_queued_for_deletion(): return
	if 0 in Audio._music_channels:
		Audio._music_channels[0].process_mode = Node.PROCESS_MODE_DISABLED
	
	if Input.is_action_just_pressed(&"ui_cancel"):
		Scenes.custom_scenes.pause.open_blocked = true
		hide()
		Scenes.current_scene = Data.technical_values.main_menu_scene
		Scenes.current_scene.process_mode = Node.PROCESS_MODE_INHERIT
		Audio.stop_music_channel(2, false) # death
		Audio.stop_music_channel(1, false) # game over
		Audio.stop_music_channel(98, false) # starman
		if 0 in Audio._music_channels:
			Audio._music_channels[0].process_mode = Node.PROCESS_MODE_ALWAYS
		_is_stage_ready = false
		await get_tree().physics_frame
		queue_free()

func _exit_tree() -> void:
	Data.values.lives = 4
	Data.values.score = 0
	Console.cv.item_display_shown = false
	if 98 in Audio._music_channels && is_instance_valid(Audio._music_channels[98]):
		Audio._music_channels[98].queue_free()

func restart() -> void:
	Scenes.current_scene.queue_free()
	if 98 in Audio._music_channels && is_instance_valid(Audio._music_channels[98]):
		Audio._music_channels[98].queue_free()
	if !Scenes._current_scene_buffer || Scenes._current_scene_buffer.resource_path != scene_file_path:
		Scenes._current_scene_buffer = load(scene_file_path)
	Scenes.current_scene = Scenes._current_scene_buffer.instantiate()
	add_sibling.call_deferred(Scenes.current_scene)
	get_tree().paused = false
	#Scenes.scene_ready.emit()


func _on_player_died() -> void:
	Audio.stop_music_channel(98, false) # starman
