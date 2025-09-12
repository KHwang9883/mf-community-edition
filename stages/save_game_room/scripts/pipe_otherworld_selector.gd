@icon("res://engine/objects/warps/icons/pipe_save.svg")
@tool
extends "res://engine/objects/warps/pipe_in.gd"

const SCORING = preload("res://engine/components/hud/sounds/scoring.wav")

@export
var profile_name: String
@export
var level_count: Dictionary = {
	1: 4
}
@export
var secret_level_values: Array = [
	"1-1", "1-2", "2-2", "3-3", "4-3", "5-3", "6-2", "8-3"
]
@export
var map_scene_template: String = ""
@export
var level_scene_template: String = "res://stages/extra/expert_mode/otherworld/level_{1}.tscn"
@export_node_path("Node2D") var reset_node_path: NodePath = ^"../CanvasLayer/Reset"
@export var force_disable_level_save: bool = true
@export var set_data_to_profile: String
@export var secret_name: String = "all otherworld levels found"
@export var secret_id_explicit: String = ""
@export var no_star_world_until_secret: bool = true
@export var no_secrets_label: bool = true
@export var force_warp_to_save_room: bool = false
@export var force_intro_if_level_1: bool = false
@export var clear_color_override: bool = true
@export var secret_completed: String
@export var secret_completed_kevin: String
@export var secret_completed_values: PackedStringArray

var is_empty: bool
var is_blocked: bool

var _star_world: bool = true
var _star_sel_world: int = 1
var _star_sel_level: int = 1

@onready var label: Label = $Label
@onready var reset_node: Node2D = get_node_or_null(reset_node_path)

signal save_deleted

func _ready() -> void:
	super()
	if Engine.is_editor_hint(): return
	if no_star_world_until_secret: _star_world = false
	
	_update_save()
	
	if reset_node:
		player_enter.connect(_update_reset_labels)
	else:
		print("[SavePipe] Set up the reset node path in inspector.")


func _physics_process(delta: float) -> void:
	if !player: return
	
	if _star_world && Input.is_action_just_pressed("a_tab") && !_on_warp:
		#if player.up_down == 0 && len(level_count) > 1:
			#Audio.play_1d_sound(SCORING)
			#_star_sel_world = _star_sel_world + 1 if _star_sel_world < len(level_count) else level_count.keys()[0]
			#_star_sel_level = mini(_star_sel_level, level_count[_star_sel_world])
			#label.set_world_numbers("%d-%d" % [_star_sel_world, _star_sel_level])
		#elif player.up_down < -0.5:
		var _sfx = CharacterManager.get_sound_replace(SCORING, SCORING, "menu_select_short", false)
		Audio.play_1d_sound(_sfx)
		_star_sel_level = wrapi(_star_sel_level + 1, 1, level_count[_star_sel_world] + 1)
		_update_save()
		_update_reset_labels()
	
	if !is_blocked:
		_warp_initiator()

	if !_on_warp: return
	_warping_process(delta)


func _input(event: InputEvent) -> void:
	if player == null: return
	if !(event is InputEventKey && event.is_pressed() && !event.is_echo()):
		return
	if !_star_world: return
	if _on_warp: return
	if event.keycode > 48 && event.keycode <= 57:
		if event.keycode - 48 == _star_sel_level:
			return
		if event.keycode - 48 <= level_count[_star_sel_world]:
			var _sfx = CharacterManager.get_sound_replace(SCORING, SCORING, "menu_select_short", false)
			Audio.play_1d_sound(_sfx)
			_star_sel_level = event.keycode - 48
			_update_save()
			_update_reset_labels()
	

func _update_save() -> void:
	is_blocked = false
	if clear_color_override:
		label.remove_theme_color_override(&"font_color")
		#if secret_completed && (!secret is Array || !secret_id_explicit in secret)
	if level_count.size() <= 1:
		label._tweak = true
	
	#var prof = ProfileManager.profiles.get(profile_name)
	#if prof && prof.data.get("star_world"):
	var is_not_allowed: bool
	if secret_name:
		var secret = SecretsManager.get_secret(secret_name)
		if secret_id_explicit:
			is_not_allowed = !secret || (secret is Array && !secret_id_explicit in secret)
		else:
			is_not_allowed = !secret || (secret is Array && !secret_level_values[_star_sel_level - 1] in secret)
	
	if no_star_world_until_secret && is_not_allowed:
		return
	_star_world = true
	label.set_world_numbers("%d-0" % _star_sel_level)
	if is_not_allowed:
		is_blocked = true
		label.add_theme_color_override(&"font_color", Color.LIGHT_CORAL)
		return
	
	#label.add_theme_color_override(&"font_color", Color.LIGHT_GREEN)


func pass_warp() -> void:
	ProfileManager.set_current_profile(profile_name)
	
	target = null
	
	if map_scene_template.is_empty():
		warp_to_scene = level_scene_template.format([str(_star_sel_level)])
	elif !(force_intro_if_level_1 && _star_sel_level == 1):
		warp_to_scene = map_scene_template
		if _star_sel_level > 1:
			print("Profile Started from level %d, added bit to data." % _star_sel_level)
			ProfileManager.current_profile.data.started_from_middle = true
		if _star_sel_world && level_count.size() > 1:
			ProfileManager.current_profile.data.current_world = map_scene_template.format([str(_star_sel_world)])
		if _star_sel_level:
			Data.values.map_force_selected_marker = level_scene_template.format([str(_star_sel_world), str(_star_sel_level - 1)])
			Data.values.map_force_go_next = true
	
	if force_warp_to_save_room:
		ProfileManager.current_profile.data.warp_to_save_room = true
	Data.values.skip_progress_continue = true
	# Activate Kevin in saved pipe on enter
	if KevinGlobal.activated:
		ProfileManager.current_profile.data.kevin_mode_enabled = true
	if set_data_to_profile:
		ProfileManager.current_profile.data[set_data_to_profile] = true
	await get_tree().physics_frame
	super()


func _update_reset_labels() -> void:
	#if reset_node.unlock:
		#reset_node.unlock.visible = _star_world
	reset_node.unlock2.visible = _star_world
	
	reset_node.secrets.visible = true
	if no_secrets_label || !secret_name:
		reset_node.secrets.visible = false
		return
	var secret = SecretsManager.get_secret(secret_name)
	if !secret || (secret is Array && !secret_level_values[_star_sel_level - 1] in secret):
		reset_node.secrets.text = "level locked! find a passage in expert mode worlds!"
	else:
		reset_node.secrets.text = "you have found this level in expert %s" % secret_level_values[_star_sel_level - 1]
	
		
