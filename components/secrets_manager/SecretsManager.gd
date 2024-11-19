extends CanvasLayer

const secrets_path = "user://achievements.thss"
const SECRET_NOTIFICATION = null

var secrets: Dictionary = {}
var toast_queue: Array[String] = []

var _save_queued: bool
var _is_free: bool = true

@onready var label: Label = $Map
@onready var ninepatch: NinePatchRect = $Map/Title
@onready var marker_2d: Marker2D = $Marker2D
@onready var vignette: Sprite2D = $Vignette

func _ready() -> void:
	load_secrets()
	reparent.call_deferred(GlobalViewport.vp, false)
	Data.life_added.connect(func():
		if Data.values.lives >= 99:
			set_secret("got 100 extra lives at once", true)
	)
	SettingsManager.tweaks_updated.connect(func():
		vignette.visible = SettingsManager.get_tweak(&"vignette", false)
	)
	await get_tree().physics_frame
	vignette.visible = SettingsManager.get_tweak(&"vignette", false)


func _physics_process(delta: float) -> void:
	if _save_queued:
		_save_queued = false
		SettingsManager.save_data(secrets, secrets_path, "Achievements")
	if _is_free && toast_queue.size() > 0:
		_is_free = false
		show_achievement(toast_queue.pop_back())


func set_secret(secret: String, value: Variant, save: bool = true, show_toast: bool = true) -> void:
	if secret in secrets && secrets[secret] == value:
		return
	if SettingsManager.get_tweak("console_enabled", false):
		print("[Secrets Manager] Console tweak is enabled! Didn't set %s to %s" % [str(value), secret])
		return
	if !secret in secrets && show_toast && SettingsManager.get_tweak("secrets_notification", true):
		queue_achievement(secret)
	secrets[secret] = value
	if save: save_secrets()

func has_secret(secret: String) -> bool:
	return secret in secrets && secrets[secret]

func get_secret(secret: String) -> Variant:
	if secret in secrets:
		return secrets[secret]
	return null


func is_endgame() -> bool:
	return has_secret("story mode completed")


func queue_achievement(text: String) -> void:
	toast_queue.append(text)


func show_achievement(text: String) -> void:
	Audio.play_1d_sound(SECRET_NOTIFICATION)
	label.text = ""
	label.size.x = 192
	label.position.y = marker_2d.position.y + label.size.y + 8
	label.modulate.a = 1.0
	label.text = "achievement unlocked!
%s" % text
	var tw = create_tween().set_parallel()
	tw.tween_property(label, "position:y", marker_2d.position.y, 0.8)
	tw.tween_property(label, "modulate:a", marker_2d.modulate.a, 0.8).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(5.0, true, false, true).timeout
	if len(toast_queue) == 0:
		tw = create_tween()
		tw.tween_property(label, "modulate:a", 0.0, 2.0)
	
	_is_free = true


func load_secrets() -> void:
	var data: Dictionary = SettingsManager.load_data(secrets_path, "Achievements")
	if data.is_empty():
		print("A delaye, a dela. A delayed gamne, a delayepb. Bad Game Design.")
		return
	
	secrets = data
	print("[Secrets Manager] Achievements loaded.")

func save_secrets() -> void:
	_save_queued = true
	
