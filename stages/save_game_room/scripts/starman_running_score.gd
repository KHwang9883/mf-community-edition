extends Label

func _ready() -> void:
	var t = SecretsManager.get_secret("starman_score")
	if !t:
		text = str(0)
	else:
		text = str(t)
