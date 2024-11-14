@icon("res://engine/objects/warps/icons/pipe_save.svg")
@tool
extends "res://engine/objects/warps/pipe_in.gd"

@export
var profile_name: String
@export
var level_count: Dictionary = {
	1: 4
}
@export
var map_scene_template: String = "res://stages/world_{0}/map_{0}.tscn"
@export
var level_scene_template: String = "res://stages/world_{0}/level_{0}-{1}.tscn"
@export_node_path("Node2D") var reset_node_path: NodePath = ^"../CanvasLayer/Reset"

var deletion_progress: float
var is_empty: bool
var is_cursed: bool
var is_blocked: bool
var _tweak: bool

var _star_world: bool
var _star_sel_world: int
var _star_sel_level: int

@onready var label: Label = $Label
@onready var reset_node: Node2D = get_node_or_null(reset_node_path)
@onready var kevin_activation_label: Label = $"../KevinLayer/KevinActivationLabel"
@onready var cursed_pipe: Sprite2D = $CursedPipe

signal save_deleted

func _ready() -> void:
	super()
	if Engine.is_editor_hint(): return
	player_exit.connect(func(): deletion_progress = 0)
	warp_started.connect(func():
		if KevinGlobal.activated:
			cursed_pipe.visible = true
	)
	kevin_activation_label.activated.connect(block_pure_pipe)
	kevin_activation_label.deactivated.connect(func():
		is_blocked = false
	)
	
	_tweak = SettingsManager.get_tweak("load_save_from_world_start", false)
	var prof = ProfileManager.profiles.get(profile_name)
	if prof && prof.data.get("star_world"):
		_star_world = prof.data.star_world
		var wnumbers: Array = prof.get_world_numbers().split("-")
		_star_sel_world = int(wnumbers[0])
		_star_sel_level = int(wnumbers[1])
	
	if prof && &"kevin_mode_enabled" in prof.data && prof.data.kevin_mode_enabled:
		cursed_pipe.visible = true
		is_cursed = true
	
	if KevinGlobal.activated:
		block_pure_pipe.call_deferred()
	
	if reset_node:
		player_enter.connect(_update_reset_labels)
	else:
		print("[SavePipe] Set up the reset node path in inspector.")


func _physics_process(delta: float) -> void:
	if player != null:
		if Input.is_action_pressed(&"a_delete"):
			deletion_progress = clampf(deletion_progress + delta / 3, 0, 1)
			if deletion_progress == 1:
				delete_save()
				deletion_progress = 0.0
		else:
			deletion_progress = clampf(deletion_progress - delta, 0, 1)
		
		if _star_world:
			if Input.is_action_just_pressed("a_tab") && len(level_count) > 1:
				Audio.play_1d_sound(preload("res://engine/components/hud/sounds/scoring.wav"))
				_star_sel_world = _star_sel_world + 1 if _star_sel_world < len(level_count) else level_count.keys()[0]
				_star_sel_level = mini(_star_sel_level, level_count[_star_sel_world])
				label.set_world_numbers("%d-%d" % [_star_sel_world, _star_sel_level])
		
	if !player: return
	if !is_blocked:
		_warp_initiator()
	elif player.up_down > 0 && warp_direction == Player.WarpDir.DOWN:
		player.up_down = 0
		Scenes.current_scene.get_node(^"MessageBlock").show_message.call_deferred()

	if !_on_warp: return
	_warping_process(delta)


func _input(event: InputEvent) -> void:
	if player == null: return
	if !(event is InputEventKey && event.is_pressed() && !event.is_echo()):
		return
	if _tweak || !_star_world: return
	if event.keycode > 48 && event.keycode <= 57:
		if event.keycode - 48 == _star_sel_level:
			return
		if event.keycode - 48 <= level_count[_star_sel_world]:
			Audio.play_1d_sound(preload("res://engine/components/hud/sounds/scoring.wav"))
			_star_sel_level = event.keycode - 48
			label.set_world_numbers("%d-%d" % [_star_sel_world, _star_sel_level])
	


func delete_save() -> void:
	ProfileManager.delete_profile(profile_name)
	save_deleted.emit()
	print(&"Save " + profile_name + &" deleted!")
	Audio.play_1d_sound(preload("res://engine/objects/bumping_blocks/_sounds/break.wav"))
	_star_world = false
	_update_reset_labels()
	cursed_pipe.visible = false
	is_cursed = false
	is_blocked = false


func pass_warp() -> void:
	ProfileManager.set_current_profile(profile_name)
	if _tweak:
		ProfileManager.current_profile.data.completed_levels = []
	target = null
	if _star_world && _star_sel_world:
		ProfileManager.current_profile.data.current_world = map_scene_template.format([str(_star_sel_world)])
	if _star_world && _star_sel_level:
		Data.values.map_force_selected_marker = level_scene_template.format([str(_star_sel_world), str(_star_sel_level - 1)])
		print(Data.values.map_force_selected_marker)
	if &"current_world" in ProfileManager.current_profile.data && ProfileManager.current_profile.data.current_world:
		warp_to_scene = ProfileManager.current_profile.data.current_world
	Data.values.skip_progress_continue = true
	# Activate Kevin in saved pipe on enter
	if is_cursed:
		KevinGlobal.activated = true
	if KevinGlobal.activated:
		ProfileManager.current_profile.data.kevin_mode_enabled = true
	await get_tree().physics_frame
	super()


func _update_reset_labels() -> void:
	if reset_node.unlock:
		reset_node.unlock.visible = _star_world
	reset_node.unlock2.visible = _star_world


func block_pure_pipe() -> void:
	if !is_empty && !is_cursed:
		is_blocked = true
