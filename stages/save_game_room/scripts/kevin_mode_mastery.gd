extends Control

@onready var expert_master: HBoxContainer = $VBoxContainer/ExpertMaster
@onready var u_master: HBoxContainer = $VBoxContainer/UMaster
@onready var syzx_master: HBoxContainer = $VBoxContainer/SyzxMaster
@onready var v_box_container: VBoxContainer = $VBoxContainer

func _ready() -> void:
	hide()

func activate_branch() -> void:
	show()
	
	if SecretsManager.is_console_enabled():
		return
	
	if (
		SecretsManager.has_secret("expert mode warpless") &&
		!SecretsManager.has_secret("expert mode kevin master")
	):
		check_for_expert_pipe()
	
	if (
		SecretsManager.has_secret("world u hard in kevin mode") &&
		SecretsManager.has_secret("world u normal in kevin mode") &&
		SecretsManager.has_secret("world u easy in kevin mode") &&
		!SecretsManager.has_secret("world u kevin master")
	):
		SecretsManager.set_secret("world u kevin master", true)
		v_box_container.toggle_yes(u_master.get_child(1))
	
	if (
		SecretsManager.has_secret("syzxchulun world 9 softendo kevin mode") &&
		SecretsManager.has_secret("syzxchulun world 10 advance kevin mode") &&
		SecretsManager.has_secret("syzxchulun world 12 advance kevin mode") &&
		SecretsManager.has_secret("syzxchulun world 13 advance kevin mode") &&
		!SecretsManager.has_secret("syzx worlds kevin master")
	):
		SecretsManager.set_secret(
			"syzx worlds kevin master", true, true, true, "syzxchulun worlds kevin master"
		)
		v_box_container.toggle_yes(syzx_master.get_child(1))


func check_for_expert_pipe() -> void:
	for i: String in ProfileManager.profiles.keys():
		if !i.begins_with("expert_"):
			continue
		var prof: ProfileManager.Profile = ProfileManager.profiles[i]
		if (
			prof.data.get("warped") ||
			!prof.data.get("kevin_mode_enabled") ||
			!prof.data.get("mario_forever_expert") ||
			!prof.data.get("star_world") ||
			prof.data.get("executed")
		):
			continue
		
		SecretsManager.set_secret("expert mode kevin master", true)
		v_box_container.toggle_yes(expert_master.get_child(1))
