extends Node

const score_path: String = "user://minigames.thss"
const encryption_key: int = 0xdeadbeef

@export var load_values_on_start: bool = true

var default_score_values: Dictionary = {
	_default = {
		last = 0,
		best = 0
	},
	settings = {
		minix_music = -1
	}
}
var score_values: Dictionary = default_score_values.duplicate(true)
var score_encrypted: int

@onready var node_2d: Node2D = $"../START/Node2D"

signal score_loaded
signal score_saved

func _ready() -> void:
	#if SecretsManager.is_console_enabled():
	#	Scenes.goto_scene(ProjectSettings.get_setting("application/thunder_settings/main_menu_path"))
	#	return
	Thunder._connect(score_loaded, _on_score_loaded)
	Thunder._connect(score_saved, _on_score_loaded)
	if load_values_on_start:
		load_score()
	
	Thunder._connect(Data.score_added_arg, _on_score_added)


func load_score() -> void:
	# Loading
	var path: String = score_path
	if !FileAccess.file_exists(path):
		print("[Minix Score Manager] No saved scores.")
		return
	
	var data: String = FileAccess.get_file_as_string(path)
	var dict = JSON.parse_string(data)
	
	if dict == null:
		OS.alert("Failed to load saved score_values " + name, "Can't load save file!")
		return
	
	if !"settings" in dict:
		dict.settings = score_values.settings.duplicate(false)
	else:
		for key in score_values.settings.keys():
			if key in dict.settings: continue
			dict.settings[key] = score_values.settings[key]
	score_values = dict
	score_loaded.emit()
	print("[Minix Score Manager] Loaded scores from file.")


func save_score(score: int, key: String) -> void:
	# Load with default values if "key" did not exist before
	if !key in score_values:
		score_values[key] = default_score_values._default.duplicate(true)
	
	# Calculating best highscore
	if score > score_values[key].best:
		score_values[key].best = score
	# Setting last score
	score_values[key].last = score
	
	# Saving
	var data = JSON.stringify(score_values)
	var file: FileAccess = FileAccess.open(score_path, FileAccess.WRITE)
	file.store_string(data)
	file.close()
	score_saved.emit()


func save_settings() -> void:
	# Saving
	var data = JSON.stringify(score_values)
	var file: FileAccess = FileAccess.open(score_path, FileAccess.WRITE)
	file.store_string(data)
	file.close()


func _on_score_loaded() -> void:
	await get_tree().physics_frame
	var map_count: int = len(node_2d.map_paths)
	var _achievement_get: int = 0
	
	for i in map_count:
		var minix_name: String = "minix_" + node_2d.map_names[i]
		if score_values.has(minix_name) && score_values[minix_name].get("best") >= 100000:
			_achievement_get += 1
	print("Enough points gained for achievement: %d / %d" % [_achievement_get, map_count])
	
	if _achievement_get == map_count:
		if Thunder.autosplitter.can_split_on("achievement_mfce") && !SecretsManager.has_secret("100000 points in minix maps"):
			Thunder.autosplitter.split()
		SecretsManager.set_secret("100000 points in minix maps", true, true)


func _on_score_added(scr: int) -> void:
	var score_decrypted = score_encrypted ^ encryption_key
	score_encrypted = (score_decrypted + scr) ^ encryption_key
	# enc, dec
	#prints(score_encrypted, (score_encrypted ^ encryption_key) - encryption_key)
