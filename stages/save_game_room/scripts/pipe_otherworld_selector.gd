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
		Audio.play_1d_sound(SCORING)
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
			Audio.play_1d_sound(SCORING)
			_star_sel_level = event.keycode - 48
			_update_save()
			_update_reset_labels()
	

func _update_save() -> void:
	is_blocked = false
	label.remove_theme_color_override(&"font_color")
	label._tweak = true
	
	#var prof = ProfileManager.profiles.get(profile_name)
	#if prof && prof.data.get("star_world"):
	var secret = SecretsManager.get_secret(secret_name)
	_star_world = true
	label.set_world_numbers("%d-0" % _star_sel_level)
	if !secret || (secret is Array && !secret_level_values[_star_sel_level - 1] in secret):
		is_blocked = true
		label.add_theme_color_override(&"font_color", Color.LIGHT_CORAL)
		return
	
	#label.add_theme_color_override(&"font_color", Color.LIGHT_GREEN)


func pass_warp() -> void:
	ProfileManager.set_current_profile(profile_name)
	
	target = null
	
	if map_scene_template.is_empty():
		warp_to_scene = level_scene_template.format([str(_star_sel_level)])
	else:
		warp_to_scene = map_scene_template
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
	var secret = SecretsManager.get_secret(secret_name)
	if !secret || (secret is Array && !secret_level_values[_star_sel_level - 1] in secret):
		reset_node.secrets.text = "level locked! find a passage in expert mode worlds!"
	else:
		reset_node.secrets.text = "you have found this level in expert %s" % secret_level_values[_star_sel_level - 1]
	
		
