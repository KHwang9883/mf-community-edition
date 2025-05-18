extends Marker2D

signal life_text_triggered
signal entered_castle
@export var run_crutches: bool = false

var winned: bool
@onready var fn = $"../../FinishLine"
@onready var sprite: Sprite2D = $"../../FinishLine/Finishline"
@onready var cross_area: Area2D = $"../../FinishLine/CrossingBarArea"

func _ready() -> void:
	if run_crutches:
		Data.score_added.connect(_on_score_added)
	
	if Data.values.onetime_blocks:
		Data.technical_values.saved_lives = Data.values.lives
		print("Saved lives: %d" % Data.values.lives)

func activate() -> void:
	var pl: Player = Thunder._current_player
	if !pl: return
	if !pl.completed: return
	if winned: return
	winned = true
	
	pl.no_movement = true
	pl.speed = Vector2.ZERO
	pl.warp = pl.Warp.IN
	@warning_ignore("int_as_enum_without_match", "int_as_enum_without_cast")
	pl.warp_dir = 99
	pl.sprite.set_animation(&"win")
	
	await get_tree().create_timer(1.0, false).timeout
	
	entered_castle.emit()
	var tw = create_tween()
	tw.tween_property(pl, "modulate:a", 0.0, 0.5)
	

func _on_score_added() -> void:
	var pl: Player = Thunder._current_player
	if !pl: return
	if pl.completed: return
	if is_instance_valid(sprite): sprite.use_parent_material = Data.values.score >= 0
	fn.detect_by_position = Data.values.score >= 0
	if !is_instance_valid(cross_area): return
	
	cross_area.visible = Data.values.score >= 0
	if Data.values.score >= 0:
		cross_area.process_mode = Node.PROCESS_MODE_INHERIT
	else:
		cross_area.process_mode = Node.PROCESS_MODE_DISABLED


func _on_level_completed() -> void:
	if "saved_lives" in Data.technical_values:
		if Data.technical_values.saved_lives > Data.values.lives:
			Data.values.lives = Data.technical_values.saved_lives
			Data.technical_values.erase("saved_lives")
			Audio.play_1d_sound(preload("res://engine/objects/players/prefabs/sounds/1up.wav"))
		else:
			Audio.play_1d_sound(preload("res://engine/objects/players/prefabs/sounds/powerup.wav"))
	
	life_text_triggered.emit()
	if Data.technical_values.remaining_continues != -1:
		Data.technical_values.remaining_continues += 1
	print("added a continue, total: %d" % Data.technical_values.remaining_continues)
