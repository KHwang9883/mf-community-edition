extends "res://engine/components/progress_continue/scripts/continue_sel.gd"

const message_warning_from_save: String = """warning!

one or more console commands has been activated in this save. this has affected your save data, and you will not be able to get achievements in this save until it is reset.
confirm once again to proceed."""

@export var really_yes: bool = false

@onready var progress_skipper: Node = Scenes.current_scene.get_node("Node")
@onready var message_block_2: AnimatableBody2D = Scenes.current_scene.get_node("MessageBlock2")
@onready var progress_continue: Control = $"../.."
@onready var texture_rect: TextureRect = $"../../../TextureRect"
@onready var squario_mus: int = SettingsManager.get_tweak("squario_music", 1)


func _handle_select(mouse_input: bool = false) -> void:
	if _has_started:
		return
	
	if !really_yes && (SecretsManager.is_console_enabled() || !!prog.profile.get("saved_profile_data").get("executed")):
		message_block_2.message_hidden.connect(_on_message_hidden, CONNECT_ONE_SHOT)
		texture_rect.visible = true
		progress_continue.visible = false
		progress_continue.v_box_container.focused = false
		if !!prog.profile.get("saved_profile_data").get("executed"):
			message_block_2.message = message_warning_from_save
			if Console.cv.can_save_suspended_with_console:
				message_block_2.message += "\nthe game will continue saving to this saved progress file."
			else:
				message_block_2.message += '\nthe game will not override this saved progress file. Use the "cv_forcesave_suspended" command to allow overriding.'
		message_block_2.show_message()
		return
	if !!prog.profile.get("saved_profile_data").get("executed"):
		SecretsManager._has_cheated = true
		print("Game session marked as cheated")
	if !!prog.profile.get("saved_profile_data").get("mario_forever_expert"):
		progress_skipper.mario_forever_advance(true)
	if prog.profile.get("saved_profile") && "squario" in prog.profile.saved_profile:
		if squario_mus > 0 && !SecretsManager.has_meta(&"squario_lvl_complete"):
			var squario_lvl_complete = load("res://music/extra/squario/levelcomplete.mp3")
			SecretsManager.set_meta(&"squario_lvl_complete", squario_lvl_complete)
	
	super(mouse_input)
	
	KevinGlobal.activated = !!prog.profile.get("saved_profile_data").get("kevin_mode_enabled")
	
	if SecretsManager.is_console_enabled():
		ProfileManager.current_profile.data.executed = true


func _on_message_hidden() -> void:
	texture_rect.visible = false
	progress_continue.visible = true
	really_yes = true
	await get_tree().physics_frame
	await get_tree().physics_frame
	progress_continue.v_box_container.focused = true
	
