extends Node

@onready var secret_unlocker: Node = $".."

func perform_checks_and_unlock() -> void:
	secret_unlocker.unlock_if(["damaged"], 0)
	secret_unlocker.unlock_if(["warped", "died"], 1)
	secret_unlocker.unlock_with_kevin(2)
	secret_unlocker.unlock_with_kevin_if(["warped"], 3)
	if Thunder._current_player_state.get("name") == "beetroot":
		secret_unlocker.unlock_if(["damaged"], 4)
	if Data.values.get("frog_challenge", false):
		secret_unlocker.unlock_if(["died"], 5)
		ProfileManager.current_profile.data.frog_challenged = true
	ProfileManager.current_profile.data.power_completed = Thunder._current_player_state.get("name")
	if KevinGlobal.activated && !"deaths_completed" in ProfileManager.current_profile.data:
		ProfileManager.current_profile.data.deaths_completed = Data.values.get("deaths")
