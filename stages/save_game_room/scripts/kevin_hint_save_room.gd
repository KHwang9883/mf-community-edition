extends PathFollow2D

var active: bool = false
var speed: float = 0.0
var blocked: bool = false
var is_fading: bool
var switchd: bool

@onready var cursed_preview: AnimatedSprite2D = $CursedPreview
@onready var sign_giant: Sprite2D = $"../../SignKevin"
@onready var max_progress: float = (
	func() -> float:
		var max_length: float
		var current: float = progress_ratio
		progress_ratio = 1.0
		max_length = progress
		progress_ratio = current
		return max_length
).call()
@onready var sign_mini: Sprite2D = $"../../SignMinixScore2"
@onready var mystery_arrow: Node2D = $"../../MysteryArrow"
@onready var mystery_kevin_sign: Node2D = $"../../MysteryKevinSign"
@onready var kevin_activation_label: Label = %KevinActivationLabel

var toggler_enabled: bool
var compat_cache: bool = false

func _ready() -> void:
	sign_mini.visible = SecretsManager.has_secret("hint_guy_encountered")
	mystery_arrow.visible = false
	# 通关后就应该能看到这块提示牌（以及下面那个可撞的挑战模式积木）。
	# 原本要求先成功输入过一次 KEVIN，可是积木本就是"打不了 KEVIN 时"的替代方案，
	# 手柄/触屏玩家因此永远够不到它。
	mystery_kevin_sign.visible = SecretsManager.is_endgame()
	visible = false
	sign_giant.visible = false
	if active:
		sign_mini.visible = true
		mystery_arrow.visible = true
	SettingsManager.settings_saved.connect(func():
		compat_cache = false
	)


func _physics_process(delta: float) -> void:
	if mystery_kevin_sign.visible:
		if !toggler_enabled && check_compatibility_activation():
			toggler_enabled = true
			mystery_kevin_sign.get_node("Label").text = "hit the block below\nfor a challenge mode!"
			var toggler = mystery_kevin_sign.get_node("Toggler")
			toggler.bumped.connect(func():
				if KevinGlobal.activated:
					kevin_activation_label.kevin_reset()
				else:
					kevin_activation_label.kevin_activate()
			)
			toggler.show()
			toggler.get_child(0).set_deferred(&"disabled", false)
	if !switchd && active && blocked && SecretsManager.has_secret("hint_guy_encountered"):
		if mystery_arrow.visible:
			mystery_arrow.hide()
			mystery_kevin_sign.show()
			switchd = true
	
	progress += speed * delta
	if progress > max_progress - 48 && !is_fading:
		is_fading = true
		var tw = create_tween()
		tw.tween_property(cursed_preview, "modulate:a", 0.0, 0.14)
	if progress_ratio >= 1.0:
		visible = false
		speed = 0

func activate() -> void:
	if SecretsManager.get_secret("hint_guy_encountered") || blocked:
		return
	active = true


func trigger() -> void:
	var pl = Thunder._current_player
	if !pl: return
	if !active: return
	if blocked: return
	visible = true
	blocked = true
	if !SettingsManager.get_tweak("enable_smooth_cam_transitions", true):
		progress = 96
	
	var suit_frames: SpriteFrames = SkinsManager.apply_player_skin(pl.suit)
	cursed_preview.sprite_frames = suit_frames
	cursed_preview.visible = true
	cursed_preview.play(&"walk")
	sign_giant.visible = true
	cursed_preview.speed_scale = 4
	speed = 350


func check_compatibility_activation() -> bool:
	# 手柄与触屏都打不出 "kevin"，直接用积木：触屏的 EXTRA/软键盘方案已移除。
	if !SettingsManager.device_keyboard || MobileCompat.is_touch_device():
		return true
	if compat_cache:
		return false
	var pl = Thunder._current_player
	if !pl: return false
	var checking_arr = [
		pl.control.attack, pl.control.run, pl.control.up, pl.control.down, pl.control.left,
		pl.control.right, pl.control.jump, &"m_extra", &"pause_toggle", &"ui_accept",
		&"a_delete", &"a_tab"
	]
	
	for action in checking_arr:
		if SettingsManager.settings.controls.get(action, "").to_lower() == "k":
			kevin_activation_label.set_compat_activation_only()
			return true
	
	compat_cache = true
	return false
