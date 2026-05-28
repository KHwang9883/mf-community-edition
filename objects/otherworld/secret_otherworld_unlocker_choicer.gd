extends "res://components/secrets_manager/secret_unlocker.gd"

signal otherworld_lvl_1_condition

const YOU_FOUND := "You have found a passage to %s! Would you like to go in?"
const NOW_AVAILABLE := "It is now available in the save game room at any time."

@export_multiline var you_found_text: String = "otherworld level "
@export var progress_to_int: int = 8
@onready var message_block_choicer: AnimatableBody2D = $MessageBlockChoicer

func _ready() -> void:
	super()
	Scenes.custom_scenes.otherworld_unlocker = self
	progress_to = progress_to_int
	message_block_choicer.message = YOU_FOUND % you_found_text
	if Data.technical_values.get("otherworld_lvl_1", false):
		otherworld_lvl_1_condition.emit()
	if !SecretsManager.is_console_enabled():
		message_block_choicer.message += "\n" + NOW_AVAILABLE

func tried_to_warp() -> void:
	progress_secret(0, false)

func set_shit_to_data() -> void:
	Data.technical_values.otherworld_lvl_1 = true
