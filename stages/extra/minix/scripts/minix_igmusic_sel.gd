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


func _handle_select(mouse_input: bool = false) -> void:
	return


func _physics_process(delta: float) -> void:
	super(delta)
	if !focused: return
	
	if Input.is_action_just_pressed("ui_right"):
		var old_value = starter.current_music_from_map
		starter.current_music_from_map = clamp(old_value + 1, -1, starter.map_names.size() - 1)
		_toggled_option(old_value, starter.current_music_from_map)
		
	if Input.is_action_just_pressed("ui_left"):
		var old_value = starter.current_music_from_map
		starter.current_music_from_map = clamp(old_value - 1, -1, starter.map_names.size() - 1)
		_toggled_option(old_value, starter.current_music_from_map)


func _toggled_option(old_val, new_val) -> void:
	if old_val == new_val: return
	Audio.play_1d_sound(toggle_sound, true, { "ignore_pause": true })
	_update_string()
	selection_changed.emit()
	starter.current_music_from_map = new_val
	starter.minix_score_loader.score_values.settings.minix_music = new_val
	starter.minix_score_loader.save_settings()


func _update_string() -> void:
	var mus_from_map: int = starter.current_music_from_map
	var the_text: String = starter.map_names[mus_from_map] if mus_from_map != -1 else "* default *"
	label.text = value_template % the_text
	
