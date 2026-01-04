@warning_ignore("missing_tool")
extends Stage2D

@export var goto_scene: String

@onready var color_rect: ColorRect = $CanvasLayer/ColorRect
@onready var controls: MenuItemsController = $MenuLayer/Controls
@onready var selector: MenuSelector = $MenuLayer/Selector

const POWERUP = preload("res://engine/objects/players/prefabs/sounds/powerup.wav")

var label_text_pointer: int = 0

@onready var mario_sprite: AnimatedSprite2D = $MarioSprite
@onready var kevin_sprite: AnimatedSprite2D = $KevinSprite
@onready var game_logo: Sprite2D = $Logo2

@onready var screen_camera: Camera2D = $Camera2D
var decoration_offset: float = 586.0
var tw_scroll: Tween
var started: bool

func _ready() -> void:
	if !KevinGlobal.activated and is_instance_valid(kevin_sprite):
		kevin_sprite.queue_free()
	else:
		kevin_sprite.sprite_frames = SkinsManager.apply_player_skin(CharacterManager.get_suit("small"))
		kevin_sprite.play(&"walk", 2.0)
	
	_set_obj_position(true)
	
	controls.modulate.a = 0
	selector.modulate.a = 0
	mario_sprite.sprite_frames = SkinsManager.apply_player_skin(CharacterManager.get_suit("small"))
	mario_sprite.play(&"walk", 2.0)
	
	tw_scroll = create_tween()
	tw_scroll.tween_property(self, "decoration_offset", 0.0, 7.0)
	
	await get_tree().create_timer(6.0, false).timeout
	
	if controls.focused: return
	_menu_fade_in()
	await get_tree().create_timer(0.8, false).timeout
	controls.focused = true

func _menu_fade_in() -> void:
	var tw = create_tween().set_parallel()
	tw.tween_property(controls, "modulate:a", 1, 0.8)
	tw.tween_property(selector, "modulate:a", 1, 0.8)

func start_selected() -> void:
	if !controls.focused: return
	if started: return
	started = true
	controls.focused = false
	var _sfx = CharacterManager.get_sound_replace(POWERUP, POWERUP, "hud_acceptance", false)
	Audio.play_1d_sound(_sfx)

	await get_tree().create_timer(1.2, false).timeout
	
	var tw = create_tween()
	tw.tween_property(color_rect, "modulate:a", 1, 1)
	Audio.stop_music_channel(2, true)
	await tw.finished
	
	var _crossfade: bool = SettingsManager.get_tweak("replace_circle_transitions_with_fades", false)
	
	if !_crossfade:
		TransitionManager.accept_transition(
			load("res://engine/components/transitions/circle_transition/circle_transition.tscn")
				.instantiate()
				.with_speeds(0.04, -0.1)
				.with_pause()
		)
		
		await TransitionManager.transition_middle
		Scenes.goto_scene(goto_scene)
	else:
		TransitionManager.accept_transition(
			load("res://engine/components/transitions/crossfade_transition/crossfade_transition.tscn")
				.instantiate()
				.with_scene(goto_scene)
		)

func _physics_process(delta: float) -> void:
	screen_camera.offset.x += 4.0
	_set_obj_position()

func _set_obj_position(reset_interp: bool = false) -> void:
	if is_instance_valid(kevin_sprite):
		kevin_sprite.global_position.x = screen_camera.global_position.x + decoration_offset + screen_camera.offset.x - 112.0
	mario_sprite.global_position.x = screen_camera.global_position.x + decoration_offset + screen_camera.offset.x
	game_logo.global_position.x = screen_camera.global_position.x + decoration_offset + screen_camera.offset.x - 16.0
	
	if reset_interp:
		if is_instance_valid(kevin_sprite): kevin_sprite.reset_physics_interpolation()
		mario_sprite.reset_physics_interpolation()
		game_logo.reset_physics_interpolation()

func _input(event: InputEvent) -> void:
	if started: return
	if !controls.focused and event.is_action_pressed("ui_accept", true):
		if is_instance_valid(tw_scroll):
			tw_scroll.kill()
			decoration_offset = 0.0
		_menu_fade_in()
		controls.focused = true
