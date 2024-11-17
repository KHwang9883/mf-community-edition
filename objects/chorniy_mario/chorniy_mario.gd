extends Area2D

const DEATH_SOUNDS = [
	preload("res://sfx/explode.wav"),
	preload("res://objects/chorniy_mario/death_sounds/loludied.ogg"),
	preload("res://objects/chorniy_mario/death_sounds/akh.mp3"),
	preload("res://objects/chorniy_mario/death_sounds/amogusss.ogg"),
	preload("res://objects/chorniy_mario/death_sounds/armatura_P29FH2w.mp3"),
	preload("res://objects/chorniy_mario/death_sounds/baby-laughing-meme.mp3"),
	preload("res://objects/chorniy_mario/death_sounds/blya.mp3"),
	preload("res://objects/chorniy_mario/death_sounds/blyat.mp3"),
	preload("res://objects/chorniy_mario/death_sounds/bo-womp.mp3"),
	preload("res://objects/chorniy_mario/death_sounds/bonk.ogg"),
	preload("res://objects/chorniy_mario/death_sounds/bowlingimpact2.ogg"),
	preload("res://objects/chorniy_mario/death_sounds/bowlingimpact.ogg"),
	preload("res://objects/chorniy_mario/death_sounds/cherrybomb.ogg"),
	preload("res://objects/chorniy_mario/death_sounds/couch.ogg"),
	preload("res://objects/chorniy_mario/death_sounds/crazydavescream.ogg"),
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
	preload("res://objects/chorniy_mario/death_sounds/m_fixed_eGgRdA1.mp3"),
	preload("res://objects/chorniy_mario/death_sounds/peppino-scream.mp3"),
	preload("res://objects/chorniy_mario/death_sounds/poco-x3-phone.mp3"),
	preload("res://objects/chorniy_mario/death_sounds/potato_mine.ogg"),
	preload("res://objects/chorniy_mario/death_sounds/prize.ogg"),
	preload("res://objects/chorniy_mario/death_sounds/sas1.ogg"),
	preload("res://objects/chorniy_mario/death_sounds/sb.ogg"),
	preload("res://objects/chorniy_mario/death_sounds/sci_pain.wav"),
	preload("res://objects/chorniy_mario/death_sounds/sci_shutup.wav"),
	preload("res://objects/chorniy_mario/death_sounds/sci_sneeze.wav"),
	preload("res://objects/chorniy_mario/death_sounds/smbdeath.ogg"),
	preload("res://objects/chorniy_mario/death_sounds/sndNewLuckyShot.ogg"),
	preload("res://objects/chorniy_mario/death_sounds/sndNewTeeth.ogg"),
	preload("res://objects/chorniy_mario/death_sounds/sndNewUltra.ogg"),
	preload("res://objects/chorniy_mario/death_sounds/sndserafim.ogg"),
	preload("res://objects/chorniy_mario/death_sounds/spongebob-fail.mp3"),
	preload("res://objects/chorniy_mario/death_sounds/ssbannouncer-game.mp3"),
	preload("res://objects/chorniy_mario/death_sounds/tf2-critical-hit.mp3"),
	preload("res://objects/chorniy_mario/death_sounds/xQc.ogg"),
	preload("res://objects/chorniy_mario/death_sounds/yippee-tbh.mp3"),
	preload("res://objects/chorniy_mario/death_sounds/yokarny.ogg"), preload("res://objects/chorniy_mario/death_sounds/thirdstar/BOOMHeadshot.wav.ogg"), preload("res://objects/chorniy_mario/death_sounds/thirdstar/gutsman_mcH0YtK.mp3"), preload("res://objects/chorniy_mario/death_sounds/thirdstar/mamahuevo.wav.ogg"), preload("res://objects/chorniy_mario/death_sounds/thirdstar/nenemalo.wav.ogg"), preload("res://objects/chorniy_mario/death_sounds/thirdstar/tadaaaaa.wav.ogg"), preload("res://objects/chorniy_mario/death_sounds/thirdstar/tom1.wav.ogg"), preload("res://objects/chorniy_mario/death_sounds/thirdstar/tom2.wav.ogg"), preload("res://objects/chorniy_mario/death_sounds/thirdstar/whatapp.ogg"), preload("res://objects/chorniy_mario/death_sounds/thirdstar/y2mam.mp3"), preload("res://objects/chorniy_mario/death_sounds/thirdstar/youareanidiot.wav.ogg"), preload("res://objects/chorniy_mario/death_sounds/thirdstar/zelimoment.wav.ogg"),
	preload("res://objects/chorniy_mario/death_sounds/yt1s_nijLeKo.mp3"), preload("res://objects/chorniy_mario/death_sounds/new/1093953534875144273.mp3"), preload("res://objects/chorniy_mario/death_sounds/new/1095745796407840839.mp3"), preload("res://objects/chorniy_mario/death_sounds/new/1095745887738798174.mp3"), preload("res://objects/chorniy_mario/death_sounds/new/1095747131509313566.mp3"), preload("res://objects/chorniy_mario/death_sounds/new/1096614737824993433.mp3"), preload("res://objects/chorniy_mario/death_sounds/new/1099099415270150224.mp3"), preload("res://objects/chorniy_mario/death_sounds/new/1099560657772367932.mp3"), preload("res://objects/chorniy_mario/death_sounds/new/1102241289480716368.mp3"), preload("res://objects/chorniy_mario/death_sounds/new/1102594270336123000.mp3"), preload("res://objects/chorniy_mario/death_sounds/new/1104506734153842730.mp3"), preload("res://objects/chorniy_mario/death_sounds/new/1104878321579339856.mp3"), preload("res://objects/chorniy_mario/death_sounds/new/1105208959016636416.mp3"), preload("res://objects/chorniy_mario/death_sounds/new/1105214086830108713.mp3"), preload("res://objects/chorniy_mario/death_sounds/new/1105215364368973834.mp3"), preload("res://objects/chorniy_mario/death_sounds/new/1105220320996110356.mp3"), preload("res://objects/chorniy_mario/death_sounds/new/1105242320011526285.mp3"), preload("res://objects/chorniy_mario/death_sounds/new/1105972894233804860.mp3"), preload("res://objects/chorniy_mario/death_sounds/new/1106002539092123811.mp3"), preload("res://objects/chorniy_mario/death_sounds/new/1106325550424928308.mp3"), preload("res://objects/chorniy_mario/death_sounds/new/1107736307423256747.mp3"), preload("res://objects/chorniy_mario/death_sounds/new/1108076506053365800.mp3"), preload("res://objects/chorniy_mario/death_sounds/new/1114464072872767519.mp3"), preload("res://objects/chorniy_mario/death_sounds/new/1118830880983613490-.mp3"), preload("res://objects/chorniy_mario/death_sounds/new/1129185871766228992.mp3"), preload("res://objects/chorniy_mario/death_sounds/new/1129572540973600848.mp3"), preload("res://objects/chorniy_mario/death_sounds/new/1134033733394120704-.ogg.ogg"), preload("res://objects/chorniy_mario/death_sounds/new/1136352902437404823-.ogg.ogg"), preload("res://objects/chorniy_mario/death_sounds/new/1166150655296163920-.ogg.ogg"), preload("res://objects/chorniy_mario/death_sounds/new/1180147117294108792-.ogg.ogg"), preload("res://objects/chorniy_mario/death_sounds/new/1180185072813477971-.ogg.ogg"), preload("res://objects/chorniy_mario/death_sounds/new/1190011076369195078-.ogg.ogg"), preload("res://objects/chorniy_mario/death_sounds/new/1199052635022561311-.ogg.ogg"), preload("res://objects/chorniy_mario/death_sounds/new/1222586080000475236-.ogg.ogg"), preload("res://objects/chorniy_mario/death_sounds/new/1224054896324771871-.ogg.ogg"), preload("res://objects/chorniy_mario/death_sounds/new/1236415732909211760-.ogg.ogg"), preload("res://objects/chorniy_mario/death_sounds/new/1239283343699214417-.ogg.ogg"), preload("res://objects/chorniy_mario/death_sounds/new/1249169510347444275-.ogg.ogg"), preload("res://objects/chorniy_mario/death_sounds/new/1249387845198811227-.ogg.ogg"), preload("res://objects/chorniy_mario/death_sounds/new/1249387955567460447-.ogg.ogg"), preload("res://objects/chorniy_mario/death_sounds/new/1251910109412462725-.ogg.ogg"), preload("res://objects/chorniy_mario/death_sounds/new/1252639004352974989-.ogg.ogg"), preload("res://objects/chorniy_mario/death_sounds/new/1259215278731038833-.ogg.ogg"), preload("res://objects/chorniy_mario/death_sounds/new/among.ogg"), preload("res://objects/chorniy_mario/death_sounds/new/bonus_nuke_explosion.ogg"), preload("res://objects/chorniy_mario/death_sounds/new/chicken_hit.ogg"), preload("res://objects/chorniy_mario/death_sounds/new/clash_srat_vechno.ogg"), preload("res://objects/chorniy_mario/death_sounds/new/fd.ogg"), preload("res://objects/chorniy_mario/death_sounds/new/fdsuihusd.ogg"), preload("res://objects/chorniy_mario/death_sounds/new/papap.ogg"), preload("res://objects/chorniy_mario/death_sounds/new/wrench.ogg"),
	preload("res://objects/chorniy_mario/death_sounds/very_new/1094683338704429187.mp3"), preload("res://objects/chorniy_mario/death_sounds/very_new/AAAAAAAAAAAA (1).mp3"), preload("res://objects/chorniy_mario/death_sounds/very_new/akg1.mp3"), preload("res://objects/chorniy_mario/death_sounds/very_new/bobas.ogg"), preload("res://objects/chorniy_mario/death_sounds/very_new/CYKA BLYAT.mp3"), preload("res://objects/chorniy_mario/death_sounds/very_new/flameball.ogg"), preload("res://objects/chorniy_mario/death_sounds/very_new/joj.mp3"), preload("res://objects/chorniy_mario/death_sounds/very_new/large-applause.ogg"), preload("res://objects/chorniy_mario/death_sounds/very_new/naxyi.ogg"), preload("res://objects/chorniy_mario/death_sounds/very_new/NEPRAVILNO.mp3"), preload("res://objects/chorniy_mario/death_sounds/very_new/Nice cock.mp3"), preload("res://objects/chorniy_mario/death_sounds/very_new/piano_riff.mp3"), preload("res://objects/chorniy_mario/death_sounds/very_new/POGNALI NAHOI2.mp3"), preload("res://objects/chorniy_mario/death_sounds/very_new/ptiichki let9t.mp3"), preload("res://objects/chorniy_mario/death_sounds/very_new/ryba.ogg"), preload("res://objects/chorniy_mario/death_sounds/very_new/sfx_logo.ogg"), preload("res://objects/chorniy_mario/death_sounds/very_new/SKYPE.mp3"), preload("res://objects/chorniy_mario/death_sounds/very_new/splat.wav"), preload("res://objects/chorniy_mario/death_sounds/very_new/stupidy.ogg"), preload("res://objects/chorniy_mario/death_sounds/very_new/ULETAYU.mp3"), preload("res://objects/chorniy_mario/death_sounds/very_new/_.ogg"), preload("res://objects/chorniy_mario/death_sounds/very_new/КОСПЛЕЙ ИГОРЯ.mp3"), preload("res://objects/chorniy_mario/death_sounds/very_new/Не ори блять.mp3"),
]

const EXPLOSION = preload("res://engine/objects/effects/explosion/explosion.tscn")
const APPEAR = preload("res://objects/chorniy_mario/appear.ogg")

@onready var mario: Player = Thunder._current_player
@onready var sprite = $Sprite
@onready var player = get_node_or_null("../Player")
@onready var kevin_text_2 = $KevinText2
@onready var _random_sounds_tweak: bool = SettingsManager.get_tweak("secret_mode_new_death_sounds")

var mario_pos: Vector2
var appear_triggered = false
var cutscene: bool = false
var wait_time: float

var pause: bool = false

func hide_text() -> void:
	kevin_text_2.visible = false

func _ready() -> void:
	if !is_instance_valid(mario): return
	mario_pos = mario.global_position
	reset_physics_interpolation()
	var _death_sound = DEATH_SOUNDS[1]
	if _random_sounds_tweak:
		_death_sound = DEATH_SOUNDS.pick_random()
	mario.death_music_override = _death_sound
	wait_time = mario.death_music_override.get_length() + 0.5
	mario.death_music_ignore_pause = true
	mario.died.connect(loludied)

func _physics_process(_delta: float) -> void:
	if !is_instance_valid(mario):
		if is_instance_valid(player):
			_map_process(_delta)
		return
	
	if !appear_triggered && (is_instance_valid(mario) && !mario_pos.is_equal_approx(mario.global_position) ):
		appear_triggered = true
		await get_tree().create_timer(1, false, true, false).timeout
		visible = false
		if !cutscene:
			Audio.play_1d_sound(APPEAR)
		for i in 2:
			await get_tree().physics_frame
		visible = true
	
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
	
	await get_tree().create_timer(1, false, true, false).timeout
	
	if pause: return
	
	if !is_instance_valid(mario):
		kevin_podokh()
		return
	
	global_position = pos
	sprite.animation = animation
	sprite.frame = frame
	sprite.flip_h = flip_h
	sprite.sprite_frames = frames
	
	if overlaps_body(mario) && !mario.warp && !cutscene:
		mario.die()
		kevin_podokh()

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
		await get_tree().create_timer(1, false, true, false).timeout
		visible = false
		for i in 2:
			await get_tree().physics_frame
		visible = true
	
	await get_tree().create_timer(1.0 if !player.is_faster else 0.15, false, true, false).timeout
	
	if !player.reached:
		global_position = pos
	sprite.animation = animation
	sprite.frame = frame
	sprite.flip_h = flip_h
	sprite.sprite_frames = frames

func kevin_podokh() -> void:
	queue_free()
	var ex = EXPLOSION.instantiate()
	ex.global_position = global_position
	Scenes.current_scene.add_child(ex)

func loludied() -> void:
	Data.values.lives -= 1
	Scenes.custom_scenes.pause.open_blocked = true
	Loludied.get_child(0).activate(wait_time)
