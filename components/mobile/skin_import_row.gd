extends MenuSelection

const IMPORTER_SCRIPT := preload("res://components/mobile/skin_importer.gd")
const ROW_FONT := preload("res://engine/fonts/font_variations/tweaks_font_var.tres")


func _ready() -> void:
	var label := Label.new()
	label.name = &"Label"
	label.text = "IMPORT SKIN (.ZIP)"
	label.uppercase = true
	label.add_theme_font_override(&"font", ROW_FONT)
	label.add_theme_font_size_override(&"font_size", 22)
	label.add_theme_color_override(&"font_shadow_color", Color(0, 0, 0, 0.435294))
	label.add_theme_color_override(&"font_outline_color", Color(0, 0, 0.329412, 1))
	label.add_theme_constant_override(&"line_spacing", 1)
	label.add_theme_constant_override(&"shadow_offset_x", 3)
	label.add_theme_constant_override(&"shadow_offset_y", 3)
	label.add_theme_constant_override(&"outline_size", 4)
	add_child(label)


func _handle_select(mouse_input: bool = false) -> void:
	if !focused || !get_parent().focused:
		return
	super(mouse_input)
	IMPORTER_SCRIPT.open_importer(get_tree().root)
