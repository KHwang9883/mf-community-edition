extends Node2D

var watch_for_bro: bool
var naaah_bro_died: bool

func _on_bowser_trigger_bowser_triggered() -> void:
	var tw = create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 0.6)
	watch_for_bro = true


func _physics_process(delta: float) -> void:
	if !watch_for_bro || naaah_bro_died: return
	if !Scenes.current_scene.has_node("GoombaBro13"):
		naaah_bro_died = true
		Audio.stop_all_musics(false)
		if Thunder._current_hud:
			Thunder._current_hud.pause_timer()
		await get_tree().create_timer(1.2, false, true, false).timeout
		Scenes.current_scene.finish(true)
