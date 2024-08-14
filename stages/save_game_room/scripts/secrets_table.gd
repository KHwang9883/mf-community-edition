extends VBoxContainer

@onready var children = get_children()

func _ready() -> void:
	if SecretsManager.secrets.is_empty():
		return
	
	for achievement in children:
		var toggler: Label
		var labels = achievement.get_children()
		for i in len(labels):
			if !labels[i] is Label:
				print((labels[i] as Node).get_path())
				continue
			if i == 1:
				toggler = labels[i]
				break
		
		if SecretsManager.secrets.get(achievement.secret_id) == true:
			toggle_yes(toggler)
		

func toggle_yes(label: Label) -> void:
	label.text = "yes"
	label.add_theme_color_override("font_color", Color("a8a0f8"))
