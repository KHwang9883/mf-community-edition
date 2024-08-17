extends Label

func _ready() -> void:
	text = str(SecretsManager.get_secret("starman_score"))
	if !text:
		text = str(0)
