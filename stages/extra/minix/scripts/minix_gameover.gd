extends Node2D

@onready var hud: CanvasLayer = $"../../HUD"
@onready var score: Label = $score
@onready var godlikes: Label = $godlikes
@onready var lasted: Label = $lasted
@onready var map_label: Label = $MapLabel
@onready var please_type: Node2D = $PleaseType

@onready var minix_controls: MenuItemsController = $MinixControls
@onready var starter: Node2D = $"../Node2D"
@onready var minix_score_loader: Node = $"../../MinixScoreLoader"
@onready var lasted_template: String = lasted.text


func _ready() -> void:
	please_type.visible = false
	modulate.a = 0.0
	hud.visible = false


func _on_mario_died() -> void:
	await get_tree().create_timer(4.0, false).timeout
	Pause.get_child(0).open_blocked = true

	var minix_name: String = "minix_" + starter.current_map.map_name
	minix_score_loader.save_score.call_deferred(Data.values.score, minix_name)

	get_tree().paused = true
	SettingsManager.show_mouse()
	await get_tree().physics_frame
	var tw = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tw.tween_property(self, "modulate:a", 1.0, 0.5)

	score.text = str(Data.values.score)
	if !"godlikes" in Data.values:
		Data.values.godlikes = 0
	godlikes.text = str(Data.values.godlikes)

	var secs: int = int(Data.values.lasted)
	print("Game ended with time: ", secs)
	var mins: int = floor(secs / 60)
	secs -= mins * 60

	lasted.text = lasted_template % [mins, secs]
	map_label.text = starter.map_names[starter.map_id]
	minix_controls.focused = true
	var cur_mus: int = starter.current_music_from_map
	var map_music: MinixMap = starter.current_map if cur_mus == -1 else starter.map_paths[cur_mus]
	if map_music.game_over_music:
		Audio.play_music(map_music.game_over_music, 2, {ignore_pause = true, volume = -4.0}, !map_music.start_again_on_replay)
