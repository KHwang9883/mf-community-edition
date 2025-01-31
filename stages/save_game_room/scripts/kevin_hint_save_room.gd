extends PathFollow2D

var active: bool = false
var speed: float = 0.0
var blocked: bool = false

@onready var cursed_preview: AnimatedSprite2D = $CursedPreview
@onready var sign_giant: Sprite2D = $"../../SignKevin"

func _ready() -> void:
	visible = false
	sign_giant.visible = false


func _physics_process(delta: float) -> void:
	progress += speed * delta
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
