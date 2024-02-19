extends Node

onready var rng = RandomNumberGenerator.new()

var deaths = 0
var stage = 0

const d = 32
const y0 = 0
const x0 = 0

var grid = []
# grid sizes
const nx = 14
const ny = 12


var difficulty_unlocked = 0 # read from persistent object
var highest_seen_level = 1  # read from persistent object

var reset_when_unpaused = false

var movementPressOrder = [Vector2.ZERO] 
var thisTickMovementPressOrder  = [Vector2.ZERO]

var can_die = true
var can_FS = true

var frame = 0
const seconds_per_move = 0.16666666 # 10 frames

const TARGET_FPS = 60

var new_level = false

var spause = false

var message = "paused"
var previous_message = ""

var time_start

var pauseable = false
var can_unsoftpause = false
var can_unsoftpause_timer = 0

enum FLAVORS {MOKOU, KAGUYA}

export(FLAVORS) var flavor = FLAVORS.MOKOU
var past_flavor = FLAVORS.MOKOU
var count_to_unsoftpause = false

signal pause_signal (v)
signal next_stage
signal next_stage2
signal view_message
signal signal_gate (v, i)
signal unsignal_gate (v, i)
signal supdate_gate

signal redo_scene

func redo_scene():
	emit_signal("redo_scene")

func call_gate(gategroup, id):
	emit_signal("signal_gate", gategroup, id)
	
func uncall_gate(gategroup, id):
	emit_signal("unsignal_gate", gategroup, id)

func update_gate(delta):
	emit_signal("supdate_gate", delta)

# Called when the node enters the scene tree for the first time.

func update_flavor(f):
	past_flavor = flavor
	flavor = f

func current_level():
	return  "res://world" + str(stage) + ".tscn"
	
func next_level():
	return  "res://world" + str(stage+1) + ".tscn"
	
func change_level():
	$LevelEndTimer.start(seconds_per_move)
	

func _on_LevelEndTimer_timeout():
	actually_change_level0()
	
func actually_change_level0():
	emit_signal('next_stage')
	
func actually_change_level():
	new_level = true
	print("changing LEVEL")
	emit_signal('next_stage2')
	
func actually_change_level2():
		#softpause()
	var _unused = get_tree().change_scene(global.next_level())
	stage = stage + 1
	
func show_reset():
	message = "Press 'r' to reset!"
	emit_signal('view_message')
	
	
func start_music():
	$bgmusicPlayer.play(0)
	$bgmusicPlayer.volume_db = 0.0

func pause_music():
	$bgmusicPlayer.set_stream_paused(true)
	#$titlemusicPlayer.stop()
	#$goofPlayer.stop()
	
func unpause_music():
	$bgmusicPlayer.set_stream_paused(false)
	
func pause():
	if !get_tree().paused:
		get_tree().paused = true
		$pauseSound.play(0)
		pause_music()
		previous_message = message
		message = 'Paused'
		emit_signal('pause_signal',true)
	else:
		get_tree().paused = false
		message = previous_message
		$unpauseSound.play(0)
		unpause_music()
		emit_signal('pause_signal',false)
	#get_tree().set_deferred("paused",true)
	
func softpause():
	if !get_tree().paused:
		get_tree().paused = true
		#pause_music()
		spause = true
		emit_signal('pause_signal',true)
	else:
		get_tree().paused = false
		#unpause_music()
		emit_signal('pause_signal',false)
		spause = false
	

	
func change_level2():
	emit_signal("next_stage2")
	
func end_game():
	var _unused = get_tree().change_scene("res://Ending1.tscn")
	
func play_language():
	#if !$expel.playing:
	$expel.play(0.0)
	
func play_fall():
	if !$fall.playing:
		$fall.play(0.0)
	
func play_delayed_fall():
	$delayFallTimer.start(0.5)

func play_wrap():
	#if !$wrap.playing:
	$wrap.play(0.0)


func play_break():
	if !$break.playing:
		$break.play(0.0)
	
func play_expel():
	if !$expel.playing:
		$expel.play(0.0)
		
func play_hurt():
	if !$playerHurt.playing:
		$playerHurt.play(0.0)
	
func play_telep():
	if !$telep.playing:
		$telep.play(0.0)
	
func play_win():
	if !$win.playing:
		$win.play(0.0)
	
func actually_play_delayed_fall():
	play_fall()
	
func next_level_exists():
	var file2Check = File.new()
	var file_exists = file2Check.file_exists(global.next_level())
	return file_exists
	
func any_input():
	var ret = Input.is_action_just_pressed('ui_down') or Input.is_action_just_pressed('ui_up') or Input.is_action_just_pressed('ui_left') or Input.is_action_just_pressed('ui_right') or Input.is_action_just_pressed('shoot_down') or Input.is_action_just_pressed('shoot_up') or Input.is_action_just_pressed('shoot_left') or Input.is_action_just_pressed('shoot_right')
	return ret

func set_unsoftpause_timer():
	count_to_unsoftpause = true

func _physics_process(delta):
	if spause:
		if	can_unsoftpause and any_input():
			softpause()
			can_unsoftpause = false
			can_unsoftpause_timer = 0
		elif count_to_unsoftpause:
			can_unsoftpause_timer = can_unsoftpause_timer + delta
			if can_unsoftpause_timer > 0.1:
				can_unsoftpause = true
				count_to_unsoftpause = false
	#elif Input.is_action_just_pressed("ui_cancel") and pauseable:
	#	pause()
	frame = frame + 1
	
	
	#if Input.is_action_just_pressed("ui_fullscreen"):
	#	if can_FS:
	#		OS.set_window_fullscreen(true)
	#		can_FS = false
	#	else:
	#		OS.set_window_fullscreen(false)
	#		can_FS = true
		#OS.window_fullscreen = !OS.window_fullscreen
	
	if Input.is_action_just_pressed("ui_left"):
		global.movementPressOrder.erase(Vector2.LEFT)
		global.movementPressOrder.append(Vector2.LEFT)
		global.thisTickMovementPressOrder.erase(Vector2.LEFT)
		global.thisTickMovementPressOrder.append(Vector2.LEFT)

	if Input.is_action_just_released("ui_left"):
		global.movementPressOrder.erase(Vector2.LEFT)
		
	if Input.is_action_just_pressed("ui_right"):
		global.movementPressOrder.erase(Vector2.RIGHT)
		global.movementPressOrder.append(Vector2.RIGHT)
		global.thisTickMovementPressOrder.erase(Vector2.RIGHT)
		global.thisTickMovementPressOrder.append(Vector2.RIGHT)

	if Input.is_action_just_released("ui_right"):
		global.movementPressOrder.erase(Vector2.RIGHT)
		
	if Input.is_action_just_pressed("ui_down"):
		global.movementPressOrder.erase(Vector2.DOWN)
		global.movementPressOrder.append(Vector2.DOWN)
		global.thisTickMovementPressOrder.erase(Vector2.DOWN)
		global.thisTickMovementPressOrder.append(Vector2.DOWN)

	if Input.is_action_just_released("ui_down"):
		global.movementPressOrder.erase(Vector2.DOWN)

	if Input.is_action_just_pressed("ui_up"):
		global.movementPressOrder.erase(Vector2.UP)
		global.movementPressOrder.append(Vector2.UP)
		global.thisTickMovementPressOrder.erase(Vector2.UP)
		global.thisTickMovementPressOrder.append(Vector2.UP)

	if Input.is_action_just_released("ui_up"):
		global.movementPressOrder.erase(Vector2.UP)
		



func _ready():
	pass
	
func play_title():
	$titlemusicPlayer.volume_db = 0.0
	$titlemusicPlayer.play(0.0)
	
func stop_title():
	$titlemusicPlayer.stop()
	
func play_goof():
	$goofPlayer.volume_db = 0.0
	$goofPlayer.play(0.0)
	
func stop_goof():
	$goofPlayer.stop()
	
func music_fade():
	$AnimationPlayer.play("musicfade")

func bgmusic_playing():
	return $bgmusicPlayer.playing

func map_to_world(cell):
	return Vector2(x0+ d*cell.x,y0 + d*cell.y);
	
func world_to_map(pos):
	# should ideally have some tolerance and not just round
	var ix = round((pos.x-x0)/d)
	var iy = round((pos.y-y0)/d)
	return Vector2(ix,iy)
	
	
func get_world(cell):
	return map_to_world(cell) + d/2.0 * Vector2.ONE

func make_2d_array():
	var array = [];
	for iy in ny:
		array.append([]);
		for ix in nx:
			array[iy].append(null);
	return array


func load_lastscore():
	var file = File.new()
	var farr = []
	if file.file_exists("user://score.dat"):
		file.open("user://score.dat", File.READ)
		var content = file.get_as_text()
		file.close()
		var strarr = content.split("\n")
		for this_str in strarr:
			if len(this_str) != 0:
				farr.append(float(this_str))
			else:
				return INF
	else:
		return INF
	return farr[-1]

func save_score(time):
	var file = File.new()
	#file.open("user://score.dat", File.WRITE)
	file.open("user://score.dat", File.READ_WRITE)
	file.seek_end()
	file.store_string("\n")
	if time != INF:
		file.store_string(String(time))
	file.close()

func load_hiscores():
	var file = File.new()
	var intarr = []
	if file.file_exists("user://score.dat"):
		file.open("user://score.dat", File.READ)
		var content = file.get_as_text()
		file.close()
		var strarr = content.split("\n")
		for this_str in strarr:
			if len(this_str) == 0:
				intarr.append(INF)
			else:
				intarr.append(float(this_str))
		intarr.sort()
		intarr.invert()
	else:
		intarr = []
		file.open("user://score.dat", File.WRITE)
		#file.store_string("INF")
		file.close()
	return intarr


func _on_AnimationPlayer_animation_finished(_anim_name):
	#$goofPlayer.volume_db = 0.0
	pass


func _on_delayFallTimer_timeout():
	actually_play_delayed_fall()
