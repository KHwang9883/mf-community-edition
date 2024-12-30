extends Node

@export var normal_ids: Array[int]
@export var secret_mode_ids: Array[int]
@export var progress_ids: Array[int]
@export var progress_secret_mode_ids: Array[int]
@export var progress_reset_on_complete: bool = true
@export var check_for_softendo_mode: bool = false
@export var softendo_progress_ids: Array[int]
@export var softendo_progress_secret_mode_ids: Array[int]

@onready var secret_unlocker: Node = $".."
@onready var _tweak = ProfileManager.current_profile.data.get("advanced_edition", false)

func perform_checks_and_unlock() -> void:
	var is_advanced: bool = check_for_softendo_mode && _tweak
	if is_advanced:
		
		for i in softendo_progress_ids:
			if i == null: continue
			secret_unlocker.progress_secret(i, progress_reset_on_complete)
		if KevinGlobal.activated:
			for i in softendo_progress_secret_mode_ids:
				if i == null: continue
				secret_unlocker.progress_secret(i, progress_reset_on_complete)
		return
		
	for i in normal_ids:
		if i == null: continue
		secret_unlocker.unlock_secret(i)
	for i in secret_mode_ids:
		if i == null: continue
		secret_unlocker.unlock_with_kevin(i)
	
	for i in progress_ids:
		if i == null: continue
		secret_unlocker.progress_secret(i, progress_reset_on_complete)
	if KevinGlobal.activated:
		for i in progress_secret_mode_ids:
			if i == null: continue
			secret_unlocker.progress_secret(i, progress_reset_on_complete)
