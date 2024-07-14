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
		var old_value = starter.map_id
		starter.map_id = clamp(old_value + 1, 0, starter.map_names.size() - 1)
		_toggled_option(old_value, starter.map_id)
		
	if Input.is_action_just_pressed("ui_left"):
		var old_value = starter.map_id
		starter.map_id = clamp(old_value - 1, 0, starter.map_names.size() - 1)
		_toggled_option(old_value, starter.map_id)


func _toggled_option(old_val, new_val) -> void:
	if old_val == new_val: return
	Audio.play_1d_sound(toggle_sound, true, { "ignore_pause": true })
	_update_string()
	selection_changed.emit()
	map_changed_to.emit(new_val)


func _update_string() -> void:
	label.text = value_template % starter.map_names[starter.map_id]
	
