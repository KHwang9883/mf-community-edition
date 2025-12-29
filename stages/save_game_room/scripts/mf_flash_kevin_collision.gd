extends CollisionShape2D

#func _ready() -> void:
	#if ProfileManager.profiles.has("mf_flash_2") && ProfileManager.profiles.mf_flash_2.data.get("kevin_mode_enabled"):
		#disable()
		#return
	#%KevinActivationLabel.activated.connect(disable)
	#%KevinActivationLabel.deactivated.connect(enable)
#
#func disable():
	#set_deferred(&"disabled", true)
	#hide()
#
#func enable():
	#set_deferred(&"disabled", false)
	#show()
	#
	#var pl: Player = Thunder._current_player
	#if !pl: return
	#var rect = shape.get_rect()
	#rect.grow()
