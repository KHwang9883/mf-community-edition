extends PlayerCamera2D

@export_file("*.tscn", "*.scn") var final_cutscene: String
@export var difficulty = 0

var moving: bool = false
var can_get_faster: bool = false
var y_counter: float
var rand_offset: int = 60
var flower_counter: int = 10
var fish_preparing: bool = false
var last_player_pos: Vector2
var goomba_counter: int = 7
var use_sequence_table: bool = false

var _transition_started: bool = false
var _finish_command_started: bool

const platform = preload("res://stages/extra/climbing_minigame/objects/platform_custom/platform_path_custom.tscn")
const skulltroopa = preload("res://stages/extra/climbing_minigame/objects/paratroopa_skull/paratroopa_green_skully.tscn")
const coins = preload("res://stages/extra/climbing_minigame/objects/coins/coins.tscn")
const flower = preload("res://stages/extra/climbing_minigame/objects/fire_flower/fire_flower_lava_run.tscn")
const podoboo = preload("res://engine/objects/enemies/podoboo/podoboo.tscn")
const STIHL = preload("res://stages/extra/climbing_minigame/objects/stihl/stihl.tscn")
#var roto = preload("res://engine/objects/enemies/rotos/roto_center.tscn")
#var rotodisc = preload("res://engine/objects/enemies/rotos/roto_red.tscn")
const BIG_FISH_BONES = preload("res://stages/extra/climbing_minigame/objects/big_fish_bones/big_fish_bones.tscn")
const MARIO = preload("res://stages/extra/climbing_minigame/objects/mario.tscn")
const PLATFORM_PATH_CLOUD = preload("res://engine/objects/platform/platform_path_cloud.tscn")
#const PLATFORM_PATH_CLOUD = preload("res://engine/objects/platform/castle_platforms/long_platform.tscn")
const BULLET_LAUNCHER_STRUCTURE = preload("res://stages/extra/climbing_minigame/objects/bullet_launcher_structure/bullet_launcher_structure.tscn")
const BULLET_FIRE_LAUNCHER_STRUCTURE = preload("res://stages/extra/climbing_minigame/objects/bullet_launcher_structure/bullet_fire_launcher_structure.tscn")
const SND_BOWSER_LAUGH = preload("res://music/climbing_minigame/snd_bowser_laugh.ogg")
const LAKITU = preload("res://engine/objects/enemies/lakitus/lakitu.tscn")
const GOOMBA = preload("res://engine/objects/enemies/goombas/goomba.tscn")
const EXPERT_BULLET_LAUNCHER_STRUCTURE = preload("res://stages/extra/climbing_minigame/objects/bullet_launcher_structure/expert_bullet_launcher_structure.tscn")

const ANTIAFK = preload("res://objects/antiafk_expert_mode/antiafk_expert_mode.tscn")

@onready var platform_path: AnimatableBody2D = $"../../PlatformPath"
@onready var platform_path_2: AnimatableBody2D = $"../../PlatformPath2"
@onready var platform_path_3: AnimatableBody2D = $"../../PlatformPath3"
@onready var platform_path_4: AnimatableBody2D = $"../../PlatformPath4"
@onready var jumping_cheeps_generator: Node = $"../../JumpingCheepsGenerator"
@onready var strelochka: Sprite2D = $"../../MovingGroup/Strelochka"

@onready var volcano: Node2D = $"../Volcano"
@onready var volcano_2: Node2D = $"../Volcano2"

@onready var bowser: AnimatedSprite2D = $"../Bowser"
var projectile_inst: InstanceNode2D = preload("res://engine/objects/bosses/bowser/attacks/prefabs/hammer.tres")
var throw_sound: AudioStream = preload("res://engine/objects/projectiles/sounds/throw.wav")
var hammer_amount: int = 8
var hammer_interval: float = 0.15
var hammer_speed_min := Vector2(70, -650)
var hammer_speed_max := Vector2(500, -250)

@onready var mariomarker: Sprite2D = $"../../HUD/Mariomarker"
@onready var mariomarker_init_pos: float = mariomarker.global_position.y
@onready var goodluck: Sprite2D = $"../../HUD/Goodluck"
@onready var kevinlabel: Label = $"../../LabelKevin"

@onready var moving_group: Node2D = $".."

var bg_sounds = []

const SEQ_TABLE_EXP := {
	&"bowser_attack":     2.5,
	&"bullet_exp_create": 1.5,
	&"podo_create":   3.0,
	&"volcano_up":    4.0,
	&"big_fish_create": 1.0,
	&"bullet_create": 3.5,
	&"stihl_create":  4.5,
}
var seq_tw: Tween
var ongoing_actives: int
var max_actives: int = 3

func _ready() -> void:
	super()
	
	## Subtract from this to skip intro if onetime blocks are false
	var subtimer: float = 0.0 if Data.values.onetime_blocks else 6.8
	
	Console.executed.connect(func(command_name, args):
		if command_name == "finish":
			_finish_command_started = true
	, CONNECT_ONE_SHOT)

	#get_tree().create_timer(40, false).timeout.connect(func():
		#roto_create()
	#)

	#get_tree().create_timer(80, false).timeout.connect(func():
		#podo_create_advanced_sequence()
	#)

	y_counter = moving_group.global_position.y

	var _voices = CharacterManager.get_voice_line("oh_no")
	if Data.values.onetime_blocks:
		Audio.play_1d_sound(_voices[randi_range(0, len(_voices) - 1)])

		var tween = goodluck.create_tween().set_trans(Tween.TRANS_SINE)
		tween.tween_property(goodluck, "position:x", 256, 1).set_ease(Tween.EASE_OUT)
		tween.tween_property(goodluck, "position:x", 384, 3).set_trans(Tween.TRANS_LINEAR)
		tween.tween_property(goodluck, "position:x", 816, 1).set_ease(Tween.EASE_IN)
		tween.tween_callback(goodluck.queue_free)

	var tw = strelochka.create_tween().set_loops().set_trans(Tween.TRANS_SINE)
	tw.tween_property(strelochka, "modulate:a", 0.0, 0.5).set_ease(Tween.EASE_IN)
	tw.tween_property(strelochka, "modulate:a", 1.0, 0.5).set_ease(Tween.EASE_OUT)

	setup_platform(platform_path, randf_range(128, 568))
	setup_platform(platform_path_2, randf_range(128, 568))
	setup_platform(platform_path_3, randf_range(128, 528))
	setup_platform(platform_path_4, randf_range(128, 568))

	#Data.values['highest'] = Data.values['miles'] if 'miles' in Data.values else 0
	#Data.values['miles'] = 0

	if 'lavarun_difficulty' in Data.values:
		difficulty = Data.values['lavarun_difficulty']
	elif 'lavarun_difficulty' in Data.technical_values:
		difficulty = Data.technical_values['lavarun_difficulty']
		Data.values['lavarun_difficulty'] = difficulty
		Data.technical_values.erase('lavarun_difficulty')
	
	if 'lavarun_after' in Data.values:
		final_cutscene = Data.values['lavarun_after']
	elif 'lavarun_after' in Data.technical_values:
		final_cutscene = Data.technical_values['lavarun_after']
		Data.technical_values.erase('lavarun_after')
	
	if ProfileManager.current_profile.data.get("mario_forever_expert"):
		var antiafk = ANTIAFK.instantiate()
		antiafk.item_store_enabled = false
		antiafk.antiafk_enabled = false
		Scenes.current_scene.add_child.call_deferred(antiafk)

	await Scenes.current_scene.stage_ready

	Thunder._current_player.died_with_body.connect(death_sequence)
	if KevinGlobal.activated || (Data.values.lives == 0 && Thunder._current_player.death_check_for_lives):
		Thunder._current_player.death_stop_music = true
	
	if Data.values.onetime_blocks && difficulty >= 4 && KevinGlobal.activated:
		kevinlabel.show()
		var twwt = kevinlabel.create_tween().set_trans(Tween.TRANS_SINE)
		twwt.tween_property(kevinlabel, "position:y", 448.0, 0.5).set_ease(Tween.EASE_OUT)
		twwt.tween_interval(5.0)
		twwt.tween_property(kevinlabel, "modulate:a", 0.0, 1.0)
		twwt.tween_callback(kevinlabel.queue_free)

	use_sequence_table = difficulty == 4

	if !use_sequence_table:
		get_tree().create_timer(15 - subtimer, false).timeout.connect(big_fish_create)
		get_tree().create_timer(20 - subtimer, false).timeout.connect(podo_create)
		if difficulty > 0:
			get_tree().create_timer(25 - subtimer if difficulty < 4 else 18 - subtimer, false).timeout.connect(bullet_create)
		if difficulty > 1:
			get_tree().create_timer(25 - subtimer, false).timeout.connect(stihl_create)
		if difficulty > 2:
			get_tree().create_timer(28 - subtimer, false).timeout.connect(volcano_up)
			get_tree().create_timer(23 - subtimer, false).timeout.connect(bullet_create.bind(true))
	if difficulty > 3:
		get_tree().create_timer(12 - subtimer, false).timeout.connect(lakitu)

	await get_tree().create_timer(7.67 - subtimer, false, false, true).timeout
	moving = true
	if Audio._music_channels.get(1):
		Audio._music_channels[1].process_mode = Node.PROCESS_MODE_ALWAYS

	await get_tree().create_timer(1.0, false, false, false).timeout
	can_get_faster = true

	await get_tree().create_timer(0.4, false, false, true).timeout
	if use_sequence_table:
		seq_tw = create_tween().set_loops()
		for i in SEQ_TABLE_EXP.keys():
			seq_tw.tween_callback(_debug_print.bind(i))
			seq_tw.tween_callback(Callable(self, i))
			seq_tw.tween_interval(SEQ_TABLE_EXP[i])
	else:
		bowser_attack()
	await get_tree().create_timer(1.5, false, false, false).timeout
	jumping_cheeps_generator.enabled = true


func setup_platform(platf: AnimatableBody2D, pos: float) -> void:
	platf.collision_layer = 0
	platf.position.x = pos
	platf.add_to_group(&"kill_oob")
	platf.reset_physics_interpolation()


func teleport(sync_position_only = false, reset_interpolation: bool = false) -> void:
	player = Thunder._current_player

	if player:
		global_position.x = int(Thunder._current_player.global_position.x)
		if reset_interpolation:
			reset_physics_interpolation()

	Thunder.view.cam_border.call_deferred()


func _physics_process(_delta: float) -> void:
	super(_delta)
	
	if _finish_command_started && !TransitionManager.current_transition:
		start_transition()

	player = Thunder._current_player
	if player && player.is_on_floor() && !moving:
		platform_path.collision_layer = 112
		platform_path_2.collision_layer = 112
		platform_path_3.collision_layer = 112
		platform_path_4.collision_layer = 112

	if player:
		last_player_pos = player.global_position

	var delta = Thunder.get_delta(_delta)

	if abs(moving_group.global_position.y - y_counter) > rand_offset:
		create_platform()

	if moving:
		moving_group.global_position.y -= 1 * delta
		#if difficulty == 4:
		#	moving_group.global_position.y -= 1 * delta

		if last_player_pos.y < moving_group.global_position.y + 112 && can_get_faster:
			moving_group.global_position.y -= 2 * delta
		if last_player_pos.y < moving_group.global_position.y - 16 && can_get_faster:
			moving_group.global_position.y -= 3 * delta

	if fish_preparing:
		strelochka.position.x = move_toward(strelochka.position.x, last_player_pos.x - 27, 35 * _delta)

	mariomarker.position.y = mariomarker_init_pos + (moving_group.global_position.y / 8 / (difficulty + 1))
	if mariomarker.global_position.y < 112:
		if player:
			start_transition()
		else:
			mariomarker.global_position.y = 111
	
	
	for i in get_tree().get_nodes_in_group(&"kill_oob"):
		if !is_instance_valid(i) || !i.is_inside_tree(): continue
		if i.global_position.y > moving_group.global_position.y + 520:
			i.queue_free()

	#Data.values['miles'] = int(abs(moving_group.global_position.y))
#
	#if Data.values['highest'] < Data.values['miles']:
		#Data.values['highest'] = Data.values['miles']
	
	if Console.cv.player_stats_shown:
		kevinlabel.show()
		kevinlabel.position.y = 436
		kevinlabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		kevinlabel.text = "actives: %d" % [ongoing_actives]


func death_sequence(body: Node2D) -> void:
	await get_tree().physics_frame
	if KevinGlobal.activated:
		Thunder.reset_player_state()
		_kevin_touch()
		return
		
	if Data.values.lives == 0:
		body.wait_time = 2.5
		if is_instance_valid(Audio._music_channels.get(1)):
			Audio.stop_music_channel(1, true)
		Data.technical_values['lavarun_difficulty'] = difficulty
	
		if final_cutscene:
			Data.technical_values['lavarun_after'] = Scenes.get_scene_path(final_cutscene)
		return
	await get_tree().create_timer(2.0, false).timeout
	Thunder.reset_player_state()
	var new_player = MARIO.instantiate()
	if Data.values.lives == 0:
		new_player.death_stop_music = true
	#new_player.suit = null
	var new_plat = PLATFORM_PATH_CLOUD.instantiate()
	new_player.position = moving_group.position + Vector2(320, 160)
	new_plat.position = moving_group.position + Vector2(320, 176)
	new_plat.modulate.a = 0.01
	new_plat.z_index = -1
	Scenes.current_scene.add_child(new_player)
	Scenes.current_scene.add_child(new_plat)
	var tw = new_plat.create_tween()
	tw.tween_property(new_plat, "modulate:a", 1.0, 0.25)
	tw.tween_interval(6)
	tw.tween_property(new_plat, "modulate:a", 0.0, 0.5)
	tw.tween_callback(new_plat.queue_free)
	var tw2 = body.create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	tw2.tween_property(body, "modulate:a", 0.0, 0.5)
	tw2.tween_callback(body.queue_free)
	Thunder._current_player.invincible.call_deferred(3)
	Thunder._current_player.died_with_body.connect(death_sequence, CONNECT_DEFERRED)
	Data.values.lives -= 1


func create_platform() -> void:
	# platform spawn
	var plati = platform.instantiate()
	var _normal_pos := moving_group.global_position + Vector2(randi_range(200, 440), -50)
	var _difficult_pos := moving_group.global_position + Vector2(randi_range(150, 500), -50)
	plati.global_position = _normal_pos if difficulty < 2 else _difficult_pos
	Scenes.current_scene.add_child(plati)
	plati.add_to_group(&"kill_oob")

	rand_offset = randi_range(100, 180)
	y_counter = moving_group.global_position.y

	var left_right = randi_range(0, 1)

	# skull paratroopa spawn
	var skulli = skulltroopa.instantiate()
	skulli.global_position = Vector2(-32 if left_right else (640 + 32), randi_range(32, 400))
	skulli.velocity = Vector2(1.2, 0) if left_right else Vector2(-1.2, 0)
	var _tw = skulli.create_tween()
	_tw.tween_interval(13.0)
	_tw.tween_property(skulli, "modulate:a", 0.0, 0.5)
	_tw.tween_callback(skulli.queue_free)
	moving_group.add_child(skulli)

	# coins
	if randi_range(0, 4) == 3:
		var coinsi = coins.instantiate()
		coinsi.global_position = plati.global_position - Vector2(0, 28)
		Scenes.current_scene.add_child(coinsi)
		coinsi.add_to_group(&"kill_oob")

	# flower spawn
	flower_counter -= 1

	if flower_counter <= 0:
		var floweri = flower.instantiate()
		floweri.global_position = plati.global_position - Vector2(0, 16)
		floweri.appear_distance = 0
		floweri.force_powerup_state = true
		Scenes.current_scene.add_child(floweri)
		Thunder.reorder_on_top_of(floweri, moving_group)
		match difficulty:
			3: flower_counter = 12
			4: flower_counter = 18
			_: flower_counter = 10
	
	# goomba spawn for expert mode
	goomba_counter -= 1
	if goomba_counter <= 1 && difficulty > 3:
		var goombai = GOOMBA.instantiate()
		goombai.global_position = plati.global_position - Vector2(48, 16)
		goombai.life_time = 3
		Scenes.current_scene.add_child(goombai)
		goomba_counter = 6


#func play_bg_sound() -> void:
	#get_tree().create_timer(4, false).timeout.connect(play_bg_sound)
	#
	#var i = randi_range(0, len(bg_sounds) - 1)
	#
	#for g in range(4):
		#Audio.play_1d_sound(
			#bg_sounds[i]
		#)

var podo_hard_seq: int = -1

func podo_create(left_pos: float = 128, right_pos: float = 512, no_repeat: bool = false) -> void:
	if !use_sequence_table && !no_repeat:
		var repeat_time: float = 6.0 if difficulty < 2 else 10.0
		get_tree().create_timer(repeat_time, false).timeout.connect(podo_create.bind())
	
	if difficulty >= 2 && !use_sequence_table:
		if podo_hard_seq < 4:
			podo_hard_seq += 1
			get_tree().create_timer(0.5, false).timeout.connect(
				podo_create.bind(left_pos + 32, right_pos - 32, true)
			)
		else:
			podo_hard_seq = 0
		Audio.play_1d_sound(preload("res://engine/objects/projectiles/sounds/shoot.wav"), false)

	var podo1 = podoboo.instantiate()
	podo1.position = Vector2(left_pos, 432)
	podo1.one_shot = true
	podo1.interval = 0
	podo1.jumping = true
	podo1._on_jump()
	moving_group.add_child(podo1)

	var podo2 = podoboo.instantiate()
	podo2.position = Vector2(right_pos, 432)
	podo2.one_shot = true
	podo2.interval = 0
	podo2.jumping = true
	podo2._on_jump()
	moving_group.add_child(podo2)


func big_fish_create() -> void:
	if !use_sequence_table:
		get_tree().create_timer(15, false).timeout.connect(big_fish_create)
	strelochka.position = Vector2(last_player_pos.x, 384)
	strelochka.reset_physics_interpolation()
	fish_preparing = true

	await get_tree().create_timer(2.0, false).timeout
	ongoing_actives += 1
	await get_tree().create_timer(1.0, false).timeout
	fish_preparing = false
	var fisj = BIG_FISH_BONES.instantiate()
	fisj.position.x = strelochka.position.x
	fisj.global_position.y = moving_group.global_position.y + 480 + 96
	fisj.life_time = 3
	strelochka.position.x = -500
	strelochka.reset_physics_interpolation()
	Scenes.current_scene.add_child(fisj)
	await get_tree().create_timer(2.0, false).timeout
	ongoing_actives -= 1


func stihl_create() -> void:
	if !use_sequence_table:
		get_tree().create_timer(20, false).timeout.connect(stihl_create)

	ongoing_actives += 1
	var stihl = STIHL.instantiate()
	moving_group.add_child(stihl)
	stihl.global_position = global_position + Vector2(randi_range(-96, 480), 480)
	stihl.reset_physics_interpolation()
	var _tw = stihl.create_tween()
	_tw.tween_interval(6.0)
	_tw.tween_callback(stihl.queue_free)
	await get_tree().create_timer(3.0, false).timeout
	ongoing_actives -= 1


func bullet_create(expert: bool = false) -> void:
	if !use_sequence_table:
		get_tree().create_timer(10, false).timeout.connect(bullet_create.bind(expert))
	
	var bul
	if expert:
		bul = EXPERT_BULLET_LAUNCHER_STRUCTURE.instantiate()
	elif ProfileManager.current_profile.data.get("mario_forever_expert"):
		bul = BULLET_FIRE_LAUNCHER_STRUCTURE.instantiate()
	else:
		bul = BULLET_LAUNCHER_STRUCTURE.instantiate()
	Scenes.current_scene.add_child(bul)
	bul.global_position = Vector2(16, global_position.y - 480 - 32)
	bul.reset_physics_interpolation()


func bullet_exp_create() -> void:
	bullet_create(true)


func volcano_up() -> void:
	if !use_sequence_table:
		get_tree().create_timer(30, false).timeout.connect(volcano_up)
	
	var tw = create_tween().set_parallel()
	tw.tween_property(volcano, "position:y", 400, 1.5)
	tw.tween_property(volcano_2, "position:y", 400, 1.5)
	tw.chain().tween_interval(1.5)
	tw.chain().tween_property(volcano, "position:y", 640, 2.5)
	tw.tween_property(volcano_2, "position:y", 640, 2.5)


func lakitu() -> void:
	get_tree().create_timer(7, false).timeout.connect(lakitu)
	
	var lak = LAKITU.instantiate()
	lak.does_respawn = false
	lak.pitching_interval_max = 4
	moving_group.add_child(lak)
	lak.position += Vector2(666, 64)
	lak.reset_physics_interpolation()
	

func bowser_attack() -> void:
	Audio.play_1d_sound(preload("res://music/climbing_minigame/snd_bowser_laugh.ogg"), false)
	if difficulty < 3:
		return
	if !use_sequence_table:
		get_tree().create_timer(12, false).timeout.connect(bowser_attack)
	
	var tween_hammer: Tween = create_tween()
	tween_hammer.tween_property(bowser, "position:x", 608, 1.5)
	var pos_hammer = $"../Bowser/PosAttack"
	for i in hammer_amount:
		tween_hammer.tween_callback(
			func() -> void:
				if !projectile_inst: return
				if bowser.animation != "throw":
					bowser.play("throw")
				
				Audio.play_sound(throw_sound, bowser, false)
				NodeCreator.prepare_ins_2d(projectile_inst, bowser).create_2d().call_method(
					func(hm: Node2D) -> void:
						hm.global_position = pos_hammer.global_position
						if hm is Projectile:
							hm.belongs_to = Data.PROJECTILE_BELONGS.ENEMY
							hm.vel_set(
								Vector2(
									randf_range(hammer_speed_min.x, hammer_speed_max.x) * -1,
									randf_range(hammer_speed_min.y, hammer_speed_max.y)
								)
							)
				)
		).set_delay(0.05)
	tween_hammer.tween_callback(
		func() -> void:
			bowser.play("default")
	)
	tween_hammer.tween_property(bowser, "position:x", 688, 1.5)

#func podo_create_advanced_sequence() -> void:
	#get_tree().create_timer(30, false).timeout.connect(podo_create_advanced_sequence)
	#
	#Audio.play_1d_sound(alarm)
	#await get_tree().create_timer(4, false).timeout
	#
	#for i in range(30):
		#podo_create_advanced(i)


#func podo_create_advanced(i: int) -> void:
	#await get_tree().create_timer(float(i) / 4.0, false).timeout
	#Audio.play_1d_sound(woo)
	#var podo1 = podoboo.instantiate()
	#podo1.interval = 0
	#podo1.position = Vector2(320, 448-16)
	#podo1.speed.x = randi_range(-200, 200)
	#podo1.jumping_height = 400
	#podo1._on_jump()
	#podo1.get_node("Interval").queue_free()
	#moving_group.add_child(podo1)


#func roto_create() -> void:
	#get_tree().create_timer(randi_range(4, 7), false).timeout.connect(roto_create)
	#
	#var rotoi = roto.instantiate()
	#rotoi.position = Vector2(randi_range(0, 640), -256 + moving_group.global_position.y)
	#
	#var rotodisci = rotodisc.instantiate()
	#rotodisci.frequency = randi_range(-100, 100)
	#rotodisci.amplitude_changing_speed = randi_range(100, 500)
	#rotodisci.amplitude_enable = !randi_range(0, 1)
	#rotoi.add_child(rotodisci)
	#
	#Scenes.current_scene.add_child(rotoi)


func start_transition() -> void:
	if _transition_started:
		return
	_transition_started = true
	var _crossfade: bool = SettingsManager.get_tweak("replace_circle_transitions_with_fades", false)
	Data.values.checkpoint = -1
	Data.values.checked_cps = []
	Data.values.erase('lavarun_difficulty')

	if final_cutscene:
		if !_crossfade:
			TransitionManager.accept_transition(
				load("res://engine/components/transitions/circle_transition/circle_transition.tscn")
					.instantiate()
					.with_speeds(0.04, -0.1)
					.with_pause()
					.on_player_after_middle(true)
			)
			get_tree().paused = true

			await TransitionManager.transition_middle
			Scenes.goto_scene(final_cutscene)
		else:
			TransitionManager.accept_transition(
				load("res://engine/components/transitions/crossfade_transition/crossfade_transition.tscn")
					.instantiate()
					.with_scene(final_cutscene)
			)
	else:
		printerr("[Level] Jump to scene is not defined in the level.")


func _kevin_touch() -> void:
	KevinGlobal.loludied()


func _debug_print(_args) -> void:
	if !Console.debug_mode: return
	print(_args)

#func _exit_tree() -> void:
#	Thunder._disconnect(KevinGlobal.touched_kevin, _kevin_touch)
