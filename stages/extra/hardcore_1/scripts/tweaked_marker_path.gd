extends Node

@export_file("*.tscn", "*.scn") var new_level_path: String

@onready var _tweak: bool = SettingsManager.get_tweak("remade_levels", true)
@onready var _warn_tweak: bool = SettingsManager.get_tweak("show_warning_on_revamped_levels", true)
@onready var revamp_warning: Control = $RevampWarning/Control
@onready var player = Scenes.current_scene.get_node(Scenes.current_scene.player)

var is_current: bool

func _ready() -> void:
	if !new_level_path: return
	if _tweak && !_warn_tweak:
		get_parent().level = Scenes.get_scene_path(new_level_path)

func _physics_process(delta: float) -> void:
	if !_warn_tweak: return
	if is_current: return
	if !new_level_path: return
	if !player.current_marker: return
	
	if player.current_marker.get_instance_id() == get_parent().get_instance_id():
		is_current = true
		prepare_warning()


func prepare_warning() -> void:
	Scenes.current_scene.enter_on_request_only = true
	Scenes.current_scene.player_entered_level.connect(revamp_warning.toggle)
	revamp_warning.selected_new.connect(func() -> void:
		get_parent().level = Scenes.get_scene_path(new_level_path)
		Scenes.current_scene.enter_level_sequence()
	)
	revamp_warning.selected_old.connect(func() -> void:
		Scenes.current_scene.enter_level_sequence()
	)
