@tool
extends MapPlayerMarker

@onready var malpka = $Malpka
const MALPKA = preload("res://objects/map_player_marker_emalpka/malpka.wav")
var activated: bool = false

var counter: float = 0

func _ready():
	_ready_extra()
	super()

func _ready_extra() -> void:
	if Engine.is_editor_hint(): return
	
	malpka.visible = false
	
	var tweak = SettingsManager.get_tweak("minigames_in_main_worlds", false)
	
	if !tweak:
		level = ""
		level_override_save = ""

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	
	if activated:
		counter += 10 * delta
		malpka.position.y = 0 - abs(sin(counter) * 12) - 4
	
	var pl = Scenes.current_scene.get_node_or_null(Scenes.current_scene.player)
	
	if !is_instance_valid(pl): return
	
	if pl.reached && pl.current_marker == self && !activated:
		activated = true
		malpka.visible = true
		Audio.play_1d_sound(MALPKA, true, { ignore_pause = true })
		await get_tree().create_timer(0.6, true, false, true).timeout
		Audio.play_1d_sound(CharacterManager.get_voice_line("oh_no"), true, { ignore_pause = true })
