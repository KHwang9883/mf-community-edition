extends Node2D

@export var lava_seq_pos: PackedInt32Array
@export var lava_seq_speed: PackedInt32Array
@export var plat_seq_pos: PackedInt32Array
@export var plat_seq_speed: PackedInt32Array

@onready var lava_top_hud = $"../HUD/LavaTopHUD"
@onready var lava_hud = $"../HUD/LavaHUD"
@onready var platforms_main: Path2D = $"../PlatformsMain"
@onready var platform_path_4: PathFollow2D = $"../PlatformsMain/PlatformPath4"
@onready var platform_killer: Node2D = $"../PlatformKiller"
@onready var killing_positions: PackedVector2Array
@onready var platforms_to_kill: Dictionary[float, Node2D]

var lava_speed: float = 50
var step: int
var plat_step: int
var player: Player
var player_died: bool
var cam: PlayerCamera2D
var skip_frame: bool

func _ready() -> void:
	player = Thunder._current_player
	cam = Thunder._current_camera
	Data.values.checkpoint = -1
	assert(lava_seq_speed.size() == lava_seq_pos.size())
	
	var killers_count: int = platform_killer.get_child_count()
	killing_positions.resize(killers_count)
	var killers_children := platform_killer.get_children()
	var x_arr: Array[float]
	x_arr.resize(killers_count)
	for i: int in killers_count:
		killing_positions[i] = killers_children[i].position
		x_arr[i] = killers_children[i].position.x
	
	var children := platforms_main.get_children()
	for i: int in platforms_main.get_child_count():
		var found: int = x_arr.find(children[i].position.x)
		if found < 0: continue
		platforms_to_kill[children[i].position.x] = children[i]
	
	if cam:
		cam.drag_top_margin = -0.15


func _physics_process(delta: float) -> void:
	if player == null:
		if !player_died:
			koniec_gry()
			player_died = true
		return
	
	global_position.y -= lava_speed * delta
	
	lava_hud.position.y = lava_top_hud.position.y + (global_position.y - player.global_position.y - 144) / 12
	
	if step < lava_seq_pos.size():
		if global_position.y + 32 < lava_seq_pos[step]:
			lava_speed = lava_seq_speed[step]
			step += 1
	if plat_step < plat_seq_pos.size():
		if platform_path_4.global_position.y < plat_seq_pos[plat_step]:
			for pl in platforms_main.get_children():
				pl.speed = plat_seq_speed[plat_step]
			plat_step += 1
	
	for i: int in killing_positions.size():
		var pos: Vector2 = killing_positions[i]
		if pos == Vector2.ZERO: continue
		if platforms_to_kill.get(pos.x):
			if platforms_to_kill[pos.x].global_position.y < pos.y:
				platforms_to_kill[pos.x].queue_free()
				platforms_to_kill[pos.x] = null
				killing_positions[i] = Vector2.ZERO
	
	if skip_frame:
		skip_frame = false
		return
	if !player.is_on_floor() && !player.is_on_ceiling():
		return
	var pl_test_top: bool = player.test_move(player.global_transform, Vector2.UP * 50 * delta, null, 0.08, false)
	var pl_test_bottom: bool = player.test_move(player.global_transform, Vector2.DOWN * 50 * delta, null, 0.08, false)
	
	if !pl_test_top || !pl_test_bottom:
		return
	if Thunder._current_player_state && Thunder._current_player_state.type > PlayerSuit.Type.SMALL:
		player.change_suit(CharacterManager.get_suit("small"))
		skip_frame = true
		Audio.play_sound(player.suit.sound_hurt, player, false, {
			pitch = player.suit.sound_pitch, ignore_pause = true
		})
	else:
		player.die()


func koniec_gry() -> void:
	lava_speed = 0
	for pl in platforms_main.get_children():
		if !pl is PathFollow2D: continue
		pl.speed = 0
	
	var tw = create_tween().set_parallel()
	tw.tween_property(self, "lava_speed", 0.0, 0.5)
	tw.tween_property(lava_hud, "modulate:a", 0, 2)
	tw.tween_property(lava_top_hud, "modulate:a", 0, 2)
