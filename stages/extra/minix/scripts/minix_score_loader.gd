extends Node

const score_path: String = "user://minigames.thss"

@export var load_values_on_start: bool = true

var default_score_values: Dictionary = {
	_default = {
		last = 0,
		best = 0
	},
	settings = {
		minix_music = "default"
	}
}
var score_values: Dictionary = default_score_values.duplicate(true)

signal score_loaded
signal score_saved

func _ready() -> void:
	if load_values_on_start:
		load_score()


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
		score_values[key] = score_values._default.duplicate(true)
	
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
