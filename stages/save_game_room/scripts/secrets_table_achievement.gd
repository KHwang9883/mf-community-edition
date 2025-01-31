extends HBoxContainer

@export var secret_id: String
@export var progress_to: int = 0
@export var replace_with_kevin: bool = false

func _ready() -> void:
	if !replace_with_kevin:
		return
	var encount = SecretsManager.get_secret("hint_guy_encountered")
	get_child(0).text = get_child(0).text % ("kevin" if encount else "?????")
