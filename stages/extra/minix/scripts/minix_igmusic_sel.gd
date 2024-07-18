extends MenuSelection

const toggle_sound = preload("res://engine/scenes/main_menu/sounds/change.wav")

var value_template: String

@onready var starter: Node2D = $"../.."
@onready var label: Label = $Label

signal selection_changed
signal map_changed_to(map_id: int)

func _ready():
	value_template = label.text
	_update_string.call_deferred()


func _handle_select() -> void:
	return


func _physics_process(delta: float) -> void:
	super(delta)
	if !focused: return
	
	if Input.is_action_just_pressed("ui_right"):
		var old_value = starter.current_music_from_map
		var finder = starter.map_names.find(starter.current_music_from_map.map_name) + 1
		var new_value = null
		if finder >= 0 && finder < starter.map_names.size():
			new_value = starter.map_paths[finder]
		starter.current_music_from_map = new_value
		_toggled_option(old_value, starter.current_music_from_map)
		
	if Input.is_action_just_pressed("ui_left"):
		var old_value = starter.current_music_from_map
		var finder = starter.map_names.find(old_value) - 1
		var new_value = null
		if finder >= 0 && finder < starter.map_names.size():
			new_value = starter.map_paths[finder]
		starter.current_music_from_map = new_value
		_toggled_option(old_value, starter.current_music_from_map)


func _toggled_option(old_val, new_val) -> void:
	if old_val == new_val: return
	Audio.play_1d_sound(toggle_sound, true, { "ignore_pause": true })
	_update_string()
	selection_changed.emit()
	starter.current_music_from_map = new_val
	starter.minix_score_loader.score_values.settings.minix_music = new_val


func _update_string() -> void:
	var mus_from_map: MinixMap = starter.current_music_from_map
	var the_text: String = mus_from_map.map_name if mus_from_map else "default"
	label.text = value_template % the_text
	
