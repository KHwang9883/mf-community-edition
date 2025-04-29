extends SpinBox

@export_node_path("Window") var window_node_path: NodePath = ^".."
@onready var line = get_line_edit()
@onready var window_node: Window = get_node_or_null(window_node_path)

func _ready():
	# Ensure SpinBox itself can't grab focus
	focus_mode = Control.FOCUS_NONE
	#line.get_menu().prefer_native_menu = true
	#line.get_menu().set_item_text(0, "Emoji && Symbols")
	
	# line.focus_mode = Control.FOCUS_NONE
	# line.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Prevent mouse clicks from selecting it
	# Remove focus border from internal line edit
	line.add_theme_stylebox_override("focus", line.get_theme_stylebox(&"normal"))
	
	# Remove focus from LineEdit after it grabs it
	#line.text_changed.connect(_on_text_changed)
	line.focus_next = "../../HBoxContainer/ButtonOK"
	line.focus_previous = "../../HBoxContainer/ButtonCancel"
	if window_node:
		line.text_submitted.connect(_on_text_submitted)

func _on_text_changed(_new_text):
	line.release_focus()

func _on_text_submitted(_new_text: String) -> void:
	window_node.hide()
	window_node.get_parent()._on_button_pressed()
