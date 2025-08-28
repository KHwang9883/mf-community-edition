extends Node

func delete_suspended() -> void:
	if SecretsManager.is_console_enabled() && !Console.cv.can_save_suspended_with_console:
		return
	if (
		ProfileManager.profiles.has("suspended") &&
		ProfileManager.profiles.suspended.data.saved_profile == ProfileManager.current_profile.name
	):
		ProfileManager.delete_profile(&"suspended")
