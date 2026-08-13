extends Area2D

const DEATH_SOUNDS = [
	preload("res://objects/chorniy_mario/death_sounds/loludied.ogg"),preload("res://sfx/explode.wav"),
	preload("res://objects/chorniy_mario/death_sounds/very_new/tamblya-to-blya.ogg"),
	preload("res://objects/chorniy_mario/death_sounds/akh.mp3"),preload("res://objects/chorniy_mario/death_sounds/very_new/fck.ogg"),
	preload("res://objects/chorniy_mario/death_sounds/very_new/7_minutes.ogg"),preload("res://objects/chorniy_mario/death_sounds/very_new/sisyphus.ogg"),
	preload("res://objects/chorniy_mario/death_sounds/armatura_P29FH2w.mp3"),preload("res://objects/chorniy_mario/death_sounds/very_new/fallendown.mp3"),
	preload("res://objects/chorniy_mario/death_sounds/death.ogg"),
	preload("res://objects/chorniy_mario/death_sounds/blya.mp3"),preload("res://objects/chorniy_mario/death_sounds/very_new/glass_shatter.ogg"),
	preload("res://objects/chorniy_mario/death_sounds/blyat.mp3"),preload("res://objects/chorniy_mario/death_sounds/very_new/holdup.mp3"),
	preload("res://objects/chorniy_mario/death_sounds/bo-womp.mp3"),preload("res://objects/chorniy_mario/death_sounds/very_new/otval-.ogg"),
	preload("res://objects/chorniy_mario/death_sounds/bonk.ogg"),preload("res://objects/chorniy_mario/death_sounds/very_new/turkish-sitcom.ogg"),
	preload("res://objects/chorniy_mario/death_sounds/bowlingimpact2.ogg"),preload("res://objects/chorniy_mario/death_sounds/very_new/vnimanie_pozharnaya_trevog.ogg"),
	preload("res://objects/chorniy_mario/death_sounds/bowlingimpact.ogg"),preload("res://objects/chorniy_mario/death_sounds/very_new/received_money.ogg"),
	preload("res://objects/chorniy_mario/death_sounds/cherrybomb.ogg"),preload("res://objects/chorniy_mario/death_sounds/new/deaf_kev_invincible_drop.ogg"),
	preload("res://objects/chorniy_mario/death_sounds/couch.ogg"),
	preload("res://objects/chorniy_mario/death_sounds/csgo.ogg"),
	preload("res://objects/chorniy_mario/death_sounds/dark-souls-you-died-sound-effect_hm5sYFG.mp3"),
	preload("res://objects/chorniy_mario/death_sounds/discord-leave.mp3"),
	preload("res://objects/chorniy_mario/death_sounds/eralash.ogg"),
	preload("res://objects/chorniy_mario/death_sounds/explosion.ogg"),
	preload("res://objects/chorniy_mario/death_sounds/extremely-loud-incorrect-buzzer_0cDaG20.mp3"),
	preload("res://objects/chorniy_mario/death_sounds/galaxy-brain-meme.mp3"),
	preload("res://objects/chorniy_mario/death_sounds/hardcore-die-lol.ogg"),
	preload("res://objects/chorniy_mario/death_sounds/IndianAnthem.wav"),
	preload("res://objects/chorniy_mario/death_sounds/kazakhstan-ugrozhaet-nam-bombardirovkoi.mp3"),
	preload("res://objects/chorniy_mario/death_sounds/lego-yoda-death-sound-effect.mp3"),
	preload("res://objects/chorniy_mario/death_sounds/ya_vtoroi.mp3"),
	preload("res://objects/chorniy_mario/death_sounds/peppino-scream.mp3"),
	preload("res://objects/chorniy_mario/death_sounds/poco-x3-phone.mp3"),
	preload("res://objects/chorniy_mario/death_sounds/potato_mine.ogg"),
	preload("res://objects/chorniy_mario/death_sounds/prize.ogg"),
	preload("res://objects/chorniy_mario/death_sounds/sas1.ogg"),
	preload("res://objects/chorniy_mario/death_sounds/sb.ogg"),preload("res://objects/chorniy_mario/death_sounds/porrighpy.ogg"),
	preload("res://objects/chorniy_mario/death_sounds/sci_pain.wav"),preload("res://objects/chorniy_mario/death_sounds/very_new/holyshit.ogg"),
	preload("res://objects/chorniy_mario/death_sounds/sci_shutup.wav"),preload("res://objects/chorniy_mario/death_sounds/very_new/op-master48.ogg"),
	preload("res://objects/chorniy_mario/death_sounds/sci_sneeze.wav"), preload("res://objects/chorniy_mario/death_sounds/new/deltarune-party-join.ogg"), preload("res://objects/chorniy_mario/death_sounds/new/clash-king-hihihiha.ogg"), preload("res://objects/chorniy_mario/death_sounds/new/clash-king-yarr.ogg"), preload("res://objects/chorniy_mario/death_sounds/new/vineboom.ogg"), preload("res://objects/chorniy_mario/death_sounds/new/lindalinda.ogg"), preload("res://objects/chorniy_mario/death_sounds/new/chinese_scream.ogg"), preload("res://objects/chorniy_mario/death_sounds/new/among.ogg"), preload("res://objects/chorniy_mario/death_sounds/new/bonus_nuke_explosion.ogg"), preload("res://objects/chorniy_mario/death_sounds/new/chicken_hit.ogg"), preload("res://objects/chorniy_mario/death_sounds/new/clash_srat_vechno.ogg"), preload("res://objects/chorniy_mario/death_sounds/new/kirbywin.ogg"), preload("res://objects/chorniy_mario/death_sounds/new/awesome-old-boss.ogg"), preload("res://objects/chorniy_mario/death_sounds/new/papap.ogg"), preload("res://objects/chorniy_mario/death_sounds/new/wrench.ogg"),
	preload("res://objects/chorniy_mario/death_sounds/smbdeath.ogg"),preload("res://objects/chorniy_mario/death_sounds/new/hellomario.ogg"), preload("res://objects/chorniy_mario/death_sounds/new/weshipwhatever.ogg"), preload("res://objects/chorniy_mario/death_sounds/new/guitar-meme-song.ogg"), preload("res://objects/chorniy_mario/death_sounds/new/no_citizen.ogg"), preload("res://objects/chorniy_mario/death_sounds/new/green-elephant-scream.ogg"), preload("res://objects/chorniy_mario/death_sounds/new/goofy-scream.ogg"), preload("res://objects/chorniy_mario/death_sounds/new/waltuh.ogg"), preload("res://objects/chorniy_mario/death_sounds/new/correct-jingle.ogg"), preload("res://objects/chorniy_mario/death_sounds/new/byebye.ogg"), preload("res://objects/chorniy_mario/death_sounds/new/radio-good.ogg"), preload("res://objects/chorniy_mario/death_sounds/new/america.ogg"),
	preload("res://objects/chorniy_mario/death_sounds/sndNewLuckyShot.ogg"),preload("res://objects/chorniy_mario/death_sounds/very_new/prngphytf2.ogg"),
	preload("res://objects/chorniy_mario/death_sounds/sndNewTeeth.ogg"),preload("res://objects/chorniy_mario/death_sounds/star_struck/chasiki.ogg"),
	preload("res://objects/chorniy_mario/death_sounds/sndNewUltra.ogg"),preload("res://objects/chorniy_mario/death_sounds/very_new/music_02.ogg"),
	preload("res://objects/chorniy_mario/death_sounds/sndserafim.ogg"),preload("res://objects/chorniy_mario/death_sounds/dom2.mp3"),
	preload("res://objects/chorniy_mario/death_sounds/spongebob-fail.mp3"),preload("res://objects/chorniy_mario/death_sounds/ktkm9.mod"),
	preload("res://objects/chorniy_mario/death_sounds/ssbannouncer-game.mp3"),preload("res://objects/chorniy_mario/death_sounds/star_struck/bongcrash2buziol.wav.ogg"),
	preload("res://objects/chorniy_mario/death_sounds/tf2-critical-hit.mp3"),preload("res://objects/chorniy_mario/death_sounds/star_struck/MEGAMAN A57AAA.wav.ogg"), 
	preload("res://objects/chorniy_mario/death_sounds/xQc.ogg"), preload("res://objects/chorniy_mario/death_sounds/star_struck/mario_justwhatineeded.wav.ogg"),preload("res://objects/chorniy_mario/death_sounds/star_struck/da-yatupoi.ogg"), preload("res://objects/chorniy_mario/death_sounds/star_struck/NSMF2012brainrot.ogg"), preload("res://objects/chorniy_mario/death_sounds/star_struck/poshutil.ogg"), preload("res://objects/chorniy_mario/death_sounds/star_struck/SuperIdol.mp3"), preload("res://objects/chorniy_mario/death_sounds/star_struck/SMWowervorldremux.mp3"),
	preload("res://objects/chorniy_mario/death_sounds/yippee-tbh.mp3"),preload("res://objects/chorniy_mario/death_sounds/star_struck/aah.ogg"), preload("res://objects/chorniy_mario/death_sounds/star_struck/died.wav.ogg"), preload("res://objects/chorniy_mario/death_sounds/star_struck/dshoof.wav.ogg"), preload("res://objects/chorniy_mario/death_sounds/star_struck/lburn1.wav.ogg"), preload("res://objects/chorniy_mario/death_sounds/star_struck/longboing.wav.ogg"), preload("res://objects/chorniy_mario/death_sounds/star_struck/weoow.wav.ogg"), 
	preload("res://objects/chorniy_mario/death_sounds/yokarny.ogg"), preload("res://objects/chorniy_mario/death_sounds/star_struck/BOOMHeadshot.wav.ogg"), preload("res://objects/chorniy_mario/death_sounds/star_struck/gutsman_mcH0YtK.mp3"), preload("res://objects/chorniy_mario/death_sounds/star_struck/nenemalo.wav.ogg"), preload("res://objects/chorniy_mario/death_sounds/star_struck/tadaaaaa.wav.ogg"), preload("res://objects/chorniy_mario/death_sounds/star_struck/tom1.wav.ogg"), preload("res://objects/chorniy_mario/death_sounds/star_struck/tom2.wav.ogg"), preload("res://objects/chorniy_mario/death_sounds/star_struck/whatapp.ogg"), preload("res://objects/chorniy_mario/death_sounds/star_struck/y2mam.mp3"), preload("res://objects/chorniy_mario/death_sounds/star_struck/youareanidiot.wav.ogg"), preload("res://objects/chorniy_mario/death_sounds/star_struck/zelimoment.wav.ogg"),
	preload("res://objects/chorniy_mario/death_sounds/abonentskoe-uvedomlenie.ogg"), preload("res://objects/chorniy_mario/death_sounds/new/supermarioplaygrounds2.mp3"), preload("res://objects/chorniy_mario/death_sounds/new/chugun.mp3"), preload("res://objects/chorniy_mario/death_sounds/new/WOOO.mp3"), preload("res://objects/chorniy_mario/death_sounds/new/bruh.mp3"), preload("res://objects/chorniy_mario/death_sounds/new/fnaf-jumpscare.mp3"), preload("res://objects/chorniy_mario/death_sounds/new/iphone.mp3"), preload("res://objects/chorniy_mario/death_sounds/new/kazino-ebanytie.mp3"), preload("res://objects/chorniy_mario/death_sounds/new/baby-laughing.mp3"), preload("res://objects/chorniy_mario/death_sounds/new/coping.mp3"), preload("res://objects/chorniy_mario/death_sounds/new/yoweliveontwitch.mp3"), preload("res://objects/chorniy_mario/death_sounds/new/misinput.mp3"), preload("res://objects/chorniy_mario/death_sounds/new/directedby.mp3"), preload("res://objects/chorniy_mario/death_sounds/new/goofy-violine.mp3"), preload("res://objects/chorniy_mario/death_sounds/new/guitar_riff.mp3"), preload("res://objects/chorniy_mario/death_sounds/new/suggestive-music.mp3"), preload("res://objects/chorniy_mario/death_sounds/new/noice.mp3"), preload("res://objects/chorniy_mario/death_sounds/new/ris-laugh.ogg"), preload("res://objects/chorniy_mario/death_sounds/new/denied.mp3"), preload("res://objects/chorniy_mario/death_sounds/new/froggie.mp3"), preload("res://objects/chorniy_mario/death_sounds/new/loading-crash.ogg"), preload("res://objects/chorniy_mario/death_sounds/new/gd-dead.mp3"), preload("res://objects/chorniy_mario/death_sounds/new/angrybir.mp3"), preload("res://objects/chorniy_mario/death_sounds/new/halflife.mp3"),
	preload("res://objects/chorniy_mario/death_sounds/very_new/goofy-ahh-car-noise.mp3"), preload("res://objects/chorniy_mario/death_sounds/very_new/AAAAAAAAAAAA (1).mp3"), preload("res://objects/chorniy_mario/death_sounds/very_new/akg1.mp3"), preload("res://objects/chorniy_mario/death_sounds/very_new/bobas.ogg"), preload("res://objects/chorniy_mario/death_sounds/very_new/CYKA BLYAT.mp3"), preload("res://objects/chorniy_mario/death_sounds/very_new/flameball.ogg"), preload("res://objects/chorniy_mario/death_sounds/very_new/joj.mp3"), preload("res://stages/extra/click_bonus_game/sfx/appleuse.ogg"), preload("res://objects/chorniy_mario/death_sounds/very_new/naxyi.ogg"), preload("res://objects/chorniy_mario/death_sounds/very_new/NEPRAVILNO.ogg"), preload("res://objects/chorniy_mario/death_sounds/very_new/Nice cock.mp3"), preload("res://objects/chorniy_mario/death_sounds/very_new/piano_riff.mp3"), preload("res://objects/chorniy_mario/death_sounds/very_new/POGNALI NAHOI2.mp3"), preload("res://objects/chorniy_mario/death_sounds/very_new/ptiichki let9t.mp3"), preload("res://objects/chorniy_mario/death_sounds/very_new/ryba.ogg"), preload("res://objects/chorniy_mario/death_sounds/very_new/sfx_logo.ogg"), preload("res://objects/chorniy_mario/death_sounds/very_new/SKYPE.mp3"), preload("res://objects/chorniy_mario/death_sounds/very_new/splat.wav"), preload("res://stages/extra/world_of_stupidity/chmurka_debil/stupidy STAGE.wav"), preload("res://objects/chorniy_mario/death_sounds/very_new/ULETAYU.mp3"), preload("res://objects/chorniy_mario/death_sounds/very_new/КОСПЛЕЙ ИГОРЯ.mp3"), preload("res://objects/chorniy_mario/death_sounds/very_new/Не ори блять.mp3"),
	preload("res://objects/chorniy_mario/death_sounds/star_struck/arabic_tune.ogg"),preload("res://objects/chorniy_mario/death_sounds/new/media.av.extract.audio (1).mp3"),
	preload("res://objects/chorniy_mario/death_sounds/very_new/weregonnacheat.ogg"),preload("res://objects/chorniy_mario/death_sounds/new/mariochi.mod")
	,preload("res://objects/chorniy_mario/death_sounds/22/bnd_vid.ogg"),preload("res://objects/chorniy_mario/death_sounds/22/cheeki_n.ogg"),preload("res://objects/chorniy_mario/death_sounds/22/damntrain.ogg"),preload("res://objects/chorniy_mario/death_sounds/22/dolboeb.ogg"), preload("res://objects/chorniy_mario/death_sounds/22/ez.ogg"), preload("res://objects/chorniy_mario/death_sounds/22/fuuu.ogg"), preload("res://objects/chorniy_mario/death_sounds/22/headshot.wav"), preload("res://objects/chorniy_mario/death_sounds/22/idiot.ogg"), preload("res://objects/chorniy_mario/death_sounds/22/karina.ogg"), preload("res://objects/chorniy_mario/death_sounds/22/killingspree.wav"), preload("res://objects/chorniy_mario/death_sounds/22/krabik.ogg"), preload("res://objects/chorniy_mario/death_sounds/22/monsterkill.wav"), preload("res://objects/chorniy_mario/death_sounds/22/nani.ogg"), preload("res://objects/chorniy_mario/death_sounds/22/nedm.ogg"), preload("res://objects/chorniy_mario/death_sounds/22/omae.ogg"),
	preload("res://objects/chorniy_mario/death_sounds/philips.ogg")
]

const EXPLOSION = preload("res://engine/objects/effects/explosion/explosion.tscn")
const APPEAR = preload("res://objects/chorniy_mario/appear.ogg")

@onready var mario: Player = Thunder._current_player
@onready var sprite = $Sprite
@onready var player = get_node_or_null("../Player")
@onready var kevin_text_2 = $KevinText2
@onready var _random_sounds_tweak: bool = SettingsManager.get_tweak("secret_mode_new_death_sounds", true)
@onready var cloud_light_effect: Sprite2D = $CloudLightEffect
@onready var stars: CPUParticles2D = $Stars

var mario_pos: Vector2
var appear_triggered = false
var cutscene: bool = false

var pause: bool = false
var warp_invinc_timer: float

func hide_text() -> void:
	kevin_text_2.visible = false

func _ready() -> void:
	if !is_instance_valid(mario): return
	mario_pos = mario.global_position
	reset_physics_interpolation()
	if Scenes.current_scene && "expert_mode/otherworld/level_8.tscn" in Scenes.current_scene.scene_file_path:
		mario.death_music_ignore_pause = true
		var _22 = load("res://music/minix/custom/smp2_gameover.mp3")
		mario.death_music_override = _22
		mario.death_wait_time = -1
		KevinGlobal.wait_time = _22.get_length()
		return
	var _death_sound = DEATH_SOUNDS[0]
	if _random_sounds_tweak:
		_death_sound = DEATH_SOUNDS.pick_random()
	if _death_sound is String:
		_death_sound = load(_death_sound)
	mario.death_music_override = _death_sound
	KevinGlobal.wait_time = _death_sound.get_length()
	mario.death_music_ignore_pause = true


func _physics_process(delta: float) -> void:
	if !is_instance_valid(mario):
		if is_instance_valid(player):
			_map_process(delta)
		return
	if warp_invinc_timer > 0: warp_invinc_timer -= delta * 50
	
	if !appear_triggered && (is_instance_valid(mario) && mario_pos.distance_squared_to(mario.global_position) > 4 ):
		appear_triggered = true
		get_tree().create_timer(1.0, false, true).timeout.connect(func():
			visible = false
			if !cutscene:
				Audio.play_1d_sound(APPEAR, true, { ignore_pause = true })
			for i in 2:
				await get_tree().physics_frame
			visible = true
		)
	
	if !appear_triggered: return
	if !is_instance_valid(mario):
		return
	
	if mario.completed && !cutscene:
		kevin_podokh()
		return
	
	var pos: Vector2 = mario.global_position
	var animation = mario.sprite.animation
	var frame = mario.sprite.frame
	var flip_h = mario.sprite.flip_h
	var frames = mario.sprite.sprite_frames
	if mario.warp != 0 && mario.warp_dir == mario.WarpDir.UP:
		warp_invinc_timer = 15
	
	get_tree().create_timer(1.0, false, true).timeout.connect(func():
		if pause: return
		
		if !is_instance_valid(mario):
			kevin_podokh()
			return
		
		global_position = pos
		sprite.animation = animation
		sprite.frame = frame
		sprite.flip_h = flip_h
		sprite.sprite_frames = frames
	)
	
	if overlaps_body(mario) && !mario.warp && warp_invinc_timer <= 0 && !cutscene:
		mario.die()
		KevinGlobal.touched_kevin.emit()
		kevin_podokh()


var map_count: int

func _map_process(_delta: float) -> void:
	scale = Vector2(0.5, 0.5)
	
	var pos: Vector2 = player.global_position
	if !"player" in player: return
	var animation = player.player.animation
	var frame = player.player.frame
	var flip_h = player.player.flip_h
	var frames = player.player.sprite_frames
	
	if !appear_triggered:
		appear_triggered = true
		Thunder.reorder_on_top_of(self, player)
		cloud_light_effect.self_modulate.a = 0.75
	
	get_tree().create_timer(1.0 if !player.is_faster else 0.15, false, true).timeout.connect(func():
		if !player.reached:
			global_position = pos
		if map_count < 2:
			visible = false
			map_count += 1
		else:
			visible = true
			#z_index = 1
		sprite.animation = animation
		sprite.frame = frame
		sprite.flip_h = flip_h
		sprite.sprite_frames = frames
	)


func kevin_podokh() -> void:
	queue_free()
	var ex = EXPLOSION.instantiate()
	ex.global_position = global_position
	Scenes.current_scene.add_child(ex)
