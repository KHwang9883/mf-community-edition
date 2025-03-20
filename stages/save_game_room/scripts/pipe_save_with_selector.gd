@icon("res://engine/objects/warps/icons/pipe_save.svg")
@tool
extends "res://engine/objects/warps/pipe_in.gd"

const SCORING = preload("res://engine/components/hud/sounds/scoring.wav")
const message_warning_from_save: String = """warning!

one or more console cheat commands have been activated in this save. this has affected your save data, and you will not be able to get achievements in this save until it is reset.
try warping once again to proceed."""
const message_warning_forced_save: String = """warning!

one or more console cheat commands or a console tweak has been activated. the "cv_forcesave" command has been activated in this session, which will make this save permanently ineligible for achievements until it is reset.
try warping once again to proceed.
if you think that this is a mistake, please restart the game.

"""

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
@export_node_path("Label") var kevin_label_path: NodePath = ^"../KevinLayer/KevinActivationLabel"
@export var force_disable_level_save: bool = false
@export var set_data_to_profile: String

var deletion_progress: float
var is_empty: bool
var is_cursed: bool
var is_blocked: bool
var cheat_warned: bool
var _tweak: bool

var _star_world: bool
var _star_sel_world: int
var _star_sel_level: int

@onready var label: Label = $Label
@onready var reset_node: Node2D = get_node_or_null(reset_node_path)
@onready var kevin_activation_label: Label = get_node_or_null(kevin_label_path)
@onready var cursed_pipe: Sprite2D = $CursedPipe
@onready var message_block_2: AnimatableBody2D = %MessageBlock2
@onready var message_warning: String = message_block_2.message

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
	Console.executed.connect(func(cmd: String, args: Array):
		if cmd == "cv_forcesave":
			cheat_warned = false
	)
	_tweak = SettingsManager.get_tweak("load_save_from_world_start", false)
	
	_update_save()
	
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
		
		if _star_world && Input.is_action_just_pressed("a_tab"):
			if player.up_down == 0 && len(level_count) > 1:
				Audio.play_1d_sound(SCORING)
				_star_sel_world = _star_sel_world + 1 if _star_sel_world < len(level_count) else level_count.keys()[0]
				_star_sel_level = mini(_star_sel_level, level_count[_star_sel_world])
				label.set_world_numbers("%d-%d" % [_star_sel_world, _star_sel_level])
			elif player.up_down < -0.5:
				Audio.play_1d_sound(SCORING)
				_star_sel_level = wrapi(_star_sel_level + 1, 1, level_count[_star_sel_world] + 1)
				label.set_world_numbers("%d-%d" % [_star_sel_world, _star_sel_level])
	
	if !player: return
	var console_enabled: bool = SecretsManager.is_console_enabled()
	var prof = ProfileManager.profiles.get(profile_name)
	var save_is_cheated: bool = prof && prof.data.get("executed")
	
	if !is_blocked && (cheat_warned || (!console_enabled && !save_is_cheated)):
		_warp_initiator()
	elif player.up_down > 0 && warp_direction == Player.WarpDir.DOWN:
		player.up_down = 0
		if !cheat_warned && (console_enabled || save_is_cheated):
			message_block_2.message = (
				message_warning_from_save if save_is_cheated \
				else message_warning if !Console.cv.can_save_with_console \
				else message_warning_forced_save
			)
			if save_is_cheated:
				var addition: String = ""
				if Console.cv.can_save_with_console:
					addition = "\nthe game will continue saving to this save file."
				else:
					addition = '
the game will not save anything to this save file. use the "cv_forcesave" command to allow saving for this session.\n\n'
				message_block_2.message += addition
			message_block_2.show_message()
			cheat_warned = true
		else:
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
			Audio.play_1d_sound(SCORING)
			_star_sel_level = event.keycode - 48
			label.set_world_numbers("%d-%d" % [_star_sel_world, _star_sel_level])
	

func _update_save() -> void:
	is_blocked = false
	is_cursed = false
	#is_empty = false
	_star_world = false
	cheat_warned = false
	cursed_pipe.visible = false
	label.remove_theme_color_override(&"font_color")
	
	var prof = ProfileManager.profiles.get(profile_name)
	if prof && prof.data.get("star_world"):
		_star_world = prof.data.star_world
		label.add_theme_color_override(&"font_color", Color.LIGHT_GREEN)
		var wnumbers: Array
		if prof.data.get("star_numbers"):
			wnumbers = prof.data.star_numbers.split("-")
		else:
			wnumbers = prof.get_world_numbers().split("-")
		_star_sel_world = int(wnumbers[0])
		_star_sel_level = int(wnumbers[1])
		label.set_world_numbers("-".join(wnumbers))
	elif force_disable_level_save && prof:
		var world_numbers: String = prof.get_world_numbers().get_slice("-", 0)
		if !world_numbers.is_empty():
			label._tweak = true
			label.set_world_numbers(world_numbers)
	
	if prof && &"kevin_mode_enabled" in prof.data && prof.data.kevin_mode_enabled:
		cursed_pipe.visible = true
		is_cursed = true
	
	if KevinGlobal.activated:
		block_pure_pipe.call_deferred()


func delete_save() -> void:
	ProfileManager.delete_profile(profile_name)
	if ProfileManager.profiles.has("suspended") && ProfileManager.profiles.suspended.data.get("saved_profile") == profile_name:
		ProfileManager.delete_profile("suspended")
	save_deleted.emit()
	print(&"Save " + profile_name + &" deleted!")
	Audio.play_1d_sound(preload("res://engine/objects/bumping_blocks/_sounds/break.wav"))
	_star_world = false
	label.remove_theme_color_override(&"font_color")
	_update_reset_labels()
	cursed_pipe.visible = false
	is_cursed = false
	is_blocked = false


func pass_warp() -> void:
	ProfileManager.set_current_profile(profile_name)
	if SecretsManager.is_console_enabled():
		ProfileManager.current_profile.data.executed = true
	if ProfileManager.current_profile.data.get("executed"):
		SecretsManager._has_cheated = true
	
	if _tweak || (force_disable_level_save && !_star_world):
		ProfileManager.current_profile.data.completed_levels = []
		_star_sel_level = 1
	if ProfileManager.current_profile.data.get("lives") && is_cursed:
		Data.values.lives = ProfileManager.current_profile.data.lives
	target = null
	if _star_world:
		if _star_sel_level && _star_sel_world:
			ProfileManager.current_profile.data.star_numbers = &"%d-%d" % [_star_sel_world, _star_sel_level]
			ProfileManager.save_current_profile()
		if _star_sel_world:
			ProfileManager.current_profile.data.current_world = map_scene_template.format([str(_star_sel_world)])
		if _star_sel_level:
			Data.values.map_force_selected_marker = level_scene_template.format([str(_star_sel_world), str(_star_sel_level - 1)])
			Data.values.map_force_go_next = true
	
	if &"current_world" in ProfileManager.current_profile.data && ProfileManager.current_profile.data.current_world:
		warp_to_scene = ProfileManager.current_profile.data.current_world
	Data.values.skip_progress_continue = true
	# Activate Kevin in saved pipe on enter
	if is_cursed:
		KevinGlobal.activated = true
	if KevinGlobal.activated:
		ProfileManager.current_profile.data.kevin_mode_enabled = true
	if set_data_to_profile:
		ProfileManager.current_profile.data[set_data_to_profile] = true
	await get_tree().physics_frame
	super()


func _update_reset_labels() -> void:
	if reset_node.unlock:
		reset_node.unlock.visible = _star_world
	reset_node.unlock2.visible = _star_world
	reset_node.secrets.visible = false
	
	if profile_name in ProfileManager.profiles:
		var _prof = ProfileManager.profiles[profile_name].data
		if _prof.get("executed"):
			reset_node.secrets.text = "not applicable for any achievement, please reset"
			reset_node.secrets.visible = true
			return
		
		if _star_world:
			return
		
		var _arr: PackedStringArray = ["warpless", "no hit", "no deaths"]
		if "died" in _prof:
			_arr.remove_at(2)
		if "damaged" in _prof:
			_arr.remove_at(1)
		if "warped" in _prof:
			_arr.remove_at(0)
		if _arr.is_empty():
			return
		reset_node.secrets.text = "applicable for %s" % ", ".join(_arr)
		reset_node.secrets.visible = true


func block_pure_pipe() -> void:
	if !is_empty && !is_cursed:
		is_blocked = true
