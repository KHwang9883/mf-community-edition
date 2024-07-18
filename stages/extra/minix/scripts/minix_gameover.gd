extends Node2D

@onready var hud: CanvasLayer = $"../../HUD"
@onready var score: Label = $score
@onready var map_label: Label = $MapLabel
@onready var minix_controls: MenuItemsController = $MinixControls
@onready var starter: Node2D = $"../Node2D"
@onready var music_loader: Node = $MusicLoaderIntro
@onready var minix_score_loader: Node = $"../../MinixScoreLoader"


func _ready() -> void:
	modulate.a = 0.0
	hud.visible = false


func _on_mario_died() -> void:
	await get_tree().create_timer(4.0, false).timeout
	Pause.get_child(0).open_blocked = true
	
	var minix_name: String = "minix_" + starter.current_map.map_name
	minix_score_loader.save_score.call_deferred(Data.values.score, minix_name)
	
	get_tree().paused = true
	await get_tree().physics_frame
	var tw = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tw.tween_property(self, "modulate:a", 1.0, 0.5)
	
	score.text = str(Data.values.score)
	map_label.text = starter.map_names[starter.map_id]
	minix_controls.focused = true
	var map_music = starter.current_music_from_map if starter.current_music_from_map else starter.current_map
	if map_music.game_over_music:
		Audio.play_music(map_music.game_over_music, 1, {ignore_pause = true}, true)
		music_loader.play_buffered()
