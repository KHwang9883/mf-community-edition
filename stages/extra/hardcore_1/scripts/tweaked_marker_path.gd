extends Node

@export_file("*.tscn", "*.scn") var new_level_path: String
@export var set_data_only: bool = false
@export var improvements_tweak: bool = false

@onready var _tweak: bool = SettingsManager.get_tweak(
	"remade_levels" if !improvements_tweak else "improved_extra_levels", true
)
@onready var _warn_tweak: bool = SettingsManager.get_tweak(
	"show_warning_on_revamped_levels"  if !improvements_tweak else "show_warning_on_improved_levels", true
)
@onready var revamp_warning: Control = $RevampWarning/Control
@onready var player = Scenes.current_scene.get_node(Scenes.current_scene.player)

var is_current: bool

func _ready() -> void:
	if !new_level_path: return
	if improvements_tweak:
		revamp_warning._remade_tweak = _tweak
		# for improved levels, its a different tweak
		revamp_warning._warn_tweak = _warn_tweak
		revamp_warning._improved_levels = true
	if _tweak && !_warn_tweak:
		if set_data_only:
			Data.values.revamp_scene = Scenes.get_scene_path(new_level_path)
			return
		get_parent().level = Scenes.get_scene_path(new_level_path)
	if "revamp_scene" in Data.values:
		Data.values.erase("revamp_scene")

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
		if set_data_only:
			Data.values.revamp_scene = Scenes.get_scene_path(new_level_path)
		else:
			get_parent().level = Scenes.get_scene_path(new_level_path)
		Scenes.current_scene.enter_level_sequence()
	)
	revamp_warning.selected_old.connect(func() -> void:
		Scenes.current_scene.enter_level_sequence()
		if "revamp_scene" in Data.values:
			Data.values.erase("revamp_scene")
	)
