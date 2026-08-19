extends Node

const score_path: String = "user://minigames.thss"

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

@onready var node_2d: Node2D = $"../START/Node2D"
## Optional GDExtension node; null when libleaderboards failed to load.
var leaderboard_client

signal score_loaded
signal score_saved


func _enter_tree() -> void:
	_ensure_leaderboard_client()


func _ensure_leaderboard_client() -> void:
	var _override_path = OS.get_executable_path().get_base_dir().path_join("override.cfg")
	if FileAccess.file_exists(_override_path):
		print(_override_path)
		return
	if has_node(^"LeaderboardClient"):
		leaderboard_client = get_node(^"LeaderboardClient")
		return
	if !ClassDB.class_exists(&"LeaderboardClient"):
		print("[Minix Score Manager] Failed to load library!")
		return
	var client: Node = ClassDB.instantiate(&"LeaderboardClient")
	client.name = &"LeaderboardClient"
	client.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(client)
	leaderboard_client = client


func _ready() -> void:
	Thunder._connect(score_loaded, _on_score_loaded)
	Thunder._connect(score_saved, _on_score_loaded)
	if load_values_on_start:
		load_score()

	Thunder._connect(Data.score_added_arg, _on_score_added)


func load_score() -> void:
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
	if !key in score_values:
		score_values[key] = default_score_values._default.duplicate(true)

	if score > score_values[key].best:
		score_values[key].best = score
	score_values[key].last = score

	var data = JSON.stringify(score_values)
	var file: FileAccess = FileAccess.open(score_path, FileAccess.WRITE)
	file.store_string(data)
	file.close()
	score_saved.emit()


func save_settings() -> void:
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
			Thunder.autosplitter.split("MFCE Achievement")
		SecretsManager.set_secret("100000 points in minix maps", true, true)


func _on_score_added(scr: int) -> void:
	if leaderboard_client:
		leaderboard_client.track_score_added(scr)


func _on_godlike_added(godlikes: int) -> void:
	if leaderboard_client:
		leaderboard_client.track_godlikes(godlikes)
