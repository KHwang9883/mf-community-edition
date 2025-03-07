extends Marker2D

@export var stop_trigger_pos_x: float = 8000
@export_group("Projectile")
@export var projectile_inst: InstanceNode2D
@export var flame_sound: AudioStream = preload("res://engine/objects/bosses/bowser/sounds/bowser_flame.wav")
@export var flame_speed_x: float = 200
@export var base_pos_y: float = 256
## Insert number values to the array for multiple flames, numbers being offsets by Y, multiplied by 32
@export var multiple_flames: Array = []

@onready var timer: Timer = $Timer

var triggered: bool = false

func _on_bowser_trigger_bowser_triggered() -> void:
	if triggered: return
	triggered = true
	timer.start()
	_on_timer_timeout()


func _on_timer_timeout() -> void:
	var cam = Thunder._current_camera
	var pl = Thunder._current_player
	if !cam || !pl: return
	var cam_center: Vector2 = cam.get_screen_center_position()
	if cam_center.x > stop_trigger_pos_x:
		timer.stop()
		return
	
	if !projectile_inst: return
	var pos_flame: float = cam_center.x + 364
	#pos_flame.position.x = pos_flame_x * bowser.facing
	for i in max(1, len(multiple_flames)):
		NodeCreator.prepare_ins_2d(projectile_inst, self).create_2d().call_method(
			func(flm: Node2D) -> void:
				var offset = randi_range(0, 3) if len(multiple_flames) == 0 else multiple_flames[i]
				flm.global_position.y = base_pos_y + 16 - 32 * offset
				flm.global_position.x = pos_flame
				flm.flame_moving_y_speed = 0
				if flm is Projectile:
					flm.belongs_to = Data.PROJECTILE_BELONGS.ENEMY
					flm.speed.x = -abs(flame_speed_x)
				Audio.play_sound(flame_sound, flm, false)
		)
