extends Label

@export var action: String = "m_jump"
@onready var _template: String = text

func _ready() -> void:
	update_text()
	SettingsManager.settings_saved.connect(update_text)


func update_text() -> void:
	var _events: Array[InputEvent] = InputMap.action_get_events(action)
	var _event: String = "buttons on your keyboard"
	for i in _events:
		if i is InputEventKey:
			_event = i.as_text().get_slice(' (', 0) + ' button'
			break
	text = _template % [_event]
