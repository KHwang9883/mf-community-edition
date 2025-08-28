extends "res://engine/objects/bosses/bowser/bowser_lava.gd"

func _ready() -> void:
	for i in get_children():
		if i is Sprite2D:
			lava_objects.append(i)
	lava_velocity.resize(len(lava_objects))
	phases.resize(len(lava_objects))
	lava_velocity.fill(0.0)
	phases.fill(0.0)

func _set_lava_velocities(i: int) -> void: # 14
	var vel := 20.0
	phases[i] = 0
	lava_velocity[i] = vel
	var li: int = i - 1 # 13
	var ri: int = i + 1 # 15
	while vel > 0:
		await get_tree().create_timer(0.1, false).timeout
		if li >= 0:
			phases[li] = 0
			lava_velocity[li] = vel
			li -= 1 # 12 => 12 >= 0 => true
		if ri < lava_objects.size(): # 15 < 16
			phases[ri] = 0
			lava_velocity[ri] = vel
			ri += 1 # 16 => 16 < 16 => false
		vel -= 4

func lava_attack(vel: float = 192) -> void:
	var player := Thunder._current_player
	if !player: return
	var rng: bool = player.global_position.x < 320
	var range_0 := range(lava_objects.size() - 1, -1, -1)
	var range_1 := range(lava_objects.size())
	for i in range_0 if rng else range_1:
		phases[i] = 0
		lava_velocity[i] = vel
		await get_tree().create_timer(0.15, false).timeout


func _physics_process(delta: float) -> void:
	if block_logic:
		for i in len(lava_velocity):
			var vel: float = lava_velocity[i]
			if is_zero_approx(vel):
				phases[i] = 0
				continue
			if vel > 0.0:
				phases[i] -= 5 * 50 * delta
				lava_objects[i].position.y = vel * sin(phases[i] / 150.0)
				lava_velocity[i] -= 15 * delta
		return
	
	for i in len(lava_velocity):
		var vel: float = lava_velocity[i]
		if is_zero_approx(vel):
			phases[i] = 0
			continue
		if vel > 0.0:
			phases[i] += 5 * 50 * delta
			lava_objects[i].position.y = vel * sin(phases[i] / 50.0)
			lava_velocity[i] -= 0.1 * 50 * delta
