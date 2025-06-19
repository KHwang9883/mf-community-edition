extends Label


func _ready() -> void:
	var file = FileAccess.get_file_as_string("res://stages/main_menu/version-text.txt")
	file = file.strip_edges(false, true).replacen("\\n", "\n")
	var by := "by meteo dream"
	text = "version %s\n%s" % [file, by]
