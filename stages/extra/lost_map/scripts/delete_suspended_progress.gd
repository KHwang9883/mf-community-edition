extends Node

func delete_suspended() -> void:
	if (
		ProfileManager.profiles.has("suspended") &&
		ProfileManager.profiles.suspended.data.saved_profile == ProfileManager.current_profile.name
	):
		ProfileManager.delete_profile(&"suspended")
