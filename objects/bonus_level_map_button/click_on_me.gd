extends Node2D

const LAKITU_REK = preload("res://engine/objects/enemies/lakitus/sounds/lakitu_rek.ogg")

@export_file("*.tscn", "*.scn") var bonus_level_path: String

var hovered: bool
var a: float
var b: float

@onready var init_pos: Vector2 = position
@onready var click_on_me: Sprite2D = $ClickOnMe

func _ready() -> void:
	if !"bonus_game" in Data.values || !Data.values.bonus_game || !SettingsManager.get_tweak("minigames_in_main_worlds", true):
		queue_free()
		return
	
	Data.values.bonus_game = false
	modulate.a = 0.0
	create_tween().tween_property(self, "modulate:a", 1.0, 1.0)


func _physics_process(delta: float) -> void:
	if !hovered:
		click_on_me.rotation = lerp_angle(click_on_me.rotation, 0, 30 * delta)
		
		return
	a += delta * 3
	position.y = init_pos.y + sin(a) * 10
	b = -sin(a) * 20
	click_on_me.rotation = lerp_angle(click_on_me.rotation, deg_to_rad(b), 30 * delta)


func _on_mouse_entered() -> void:
	Audio.play_1d_sound(LAKITU_REK)
	hovered = true


func _on_mouse_exited() -> void:
	hovered = false


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !hovered: return
	
	if event is InputEventMouseButton && event.button_index == 1 && event.is_pressed():
		Scenes.goto_scene(bonus_level_path)
