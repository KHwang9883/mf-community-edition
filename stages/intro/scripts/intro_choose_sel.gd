extends MenuSelection

enum GameStyle {
	RECOMMENDED,
	CLASSIC,
	CUSTOM
}

enum GameLook {
	MODERN,
	SOFTENDO,
	CLASSIC
}

@export var is_game_style: bool = true
@export var selection_style: GameStyle
@export var selection_look: GameLook

@onready var tweak_presets: Control = $"../../.."

func _handle_select(mouse_input: bool = false) -> void:
	super(mouse_input)
	tweak_presets.on_choosed(is_game_style, selection_style, selection_look)
