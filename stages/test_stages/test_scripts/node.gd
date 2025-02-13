extends CanvasLayer

var SGR_SCENE: String = ProjectSettings.get_setting("application/thunder_settings/save_game_room_path")
var MENU_SCENE: String = ProjectSettings.get_setting("application/thunder_settings/main_menu_path")
@onready var THIS_SCENE: String = Scenes.current_scene.scene_file_path

@export var circle_closing_speed: float = 0.05
@export var circle_opening_speed: float = 0.1
var jump_to_scene: String

var selected: int
var on_player_after_mid: bool
var is_with_pause: bool

func _ready() -> void:
	SettingsManager.show_mouse()
	if GlobalViewport.has_node("TransTestLayer"):
		queue_free()
		return
	get_parent().remove_child.call_deferred(self)
	GlobalViewport.add_child.call_deferred(self)
	


func _on_button_pressed() -> void:
	_transition_circle()


func _transition_circle() -> void:
	# Transition (default, circle)
	TransitionManager.accept_transition(
	(
		load("res://engine/components/transitions/circle_transition/circle_transition.tscn")
			.instantiate()
			.with_speeds(circle_closing_speed, -circle_opening_speed)
			.with_pause()
			.on_player_after_middle(on_player_after_mid)
	) if is_with_pause else (
		load("res://engine/components/transitions/circle_transition/circle_transition.tscn")
			.instantiate()
			.with_speeds(circle_closing_speed, -circle_opening_speed)
			.on_player_after_middle(on_player_after_mid)
	)
	)

	if selected != 0 && selected != 3:
		var marker = _create_marker()
		TransitionManager.current_transition.on(marker) # Supports a Node2D or a Vector2
	if selected == 3:
		TransitionManager.current_transition.on(Vector2(0.5, 0.5), true)
	await TransitionManager.transition_middle

	if jump_to_scene.is_empty():
		Scenes.reload_current_scene()
	else:
		Scenes.goto_scene(jump_to_scene)
		get_tree().paused = false


func _create_marker() -> Node2D:
	if selected == 2:
		return Thunder._current_player
	
	var cam: Camera2D = Thunder._current_camera
	var marker: Marker2D
	if cam:
		var cam_pos = cam.get_screen_center_position()
		marker = Marker2D.new()
		marker.position = Vector2(
			Thunder._current_player.global_position.x,
			clamp(Thunder._current_player.global_position.y, cam_pos.y - 248, cam_pos.y + 248)
		)
		marker.reset_physics_interpolation()
		Scenes.current_scene.add_child(marker)
	return marker


func _on_option_button_item_selected(index: int) -> void:
	selected = index


func _on_check_button_2_toggled(toggled_on: bool) -> void:
	on_player_after_mid = toggled_on


func _on_check_button_3_toggled(toggled_on: bool) -> void:
	is_with_pause = toggled_on


func _on_set_scene_item_selected(index: int) -> void:
	match index:
		0: jump_to_scene = ""
		1: jump_to_scene = SGR_SCENE
		2: jump_to_scene = MENU_SCENE
		3: jump_to_scene = THIS_SCENE


func _on_button_2_pressed() -> void:
	Audio.stop_all_musics()
	Audio.stop_all_sounds()
	Scenes.goto_scene("res://stages/test_stages/circle_trans_test.tscn")
