extends TextureRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var startable = false

onready var hiscore_label = $CenterContainer/Label
# Called when the node enters the scene tree for the first time.



func _ready():
	var arr = global.load_hiscores()
	print(arr)
	if !(len(arr) == 0 or (len(arr)==1 and arr[0] == 0)):
		var hiscore = arr.min()
		if hiscore != INF:
			hiscore_label.text = "Best time: %.2f" % hiscore + " s"
	
	global.start_music()
	global.pause_music()
	global.play_title()
	#$CenterContainer/AnimationPlayer.play("bob")
	# to reset the state between games
	# we have to set the global variables to default
	# since the singleton otherwise will remember
	# and we have to always return to the title screen between games.
	
	#var _hiscores = global.load_hiscores()
	global.deaths = 0
	global.stage = 1
	global.spause = false
	global.message = "Ready?"
	global.movementPressOrder = [0]
	global.new_level = false
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func any_input():
	var ret = Input.is_action_just_pressed('ui_down') or Input.is_action_just_pressed('ui_up') or Input.is_action_just_pressed('ui_left') or Input.is_action_just_pressed('ui_right') or Input.is_action_just_pressed('shoot_down') or Input.is_action_just_pressed('shoot_up') or Input.is_action_just_pressed('shoot_left') or Input.is_action_just_pressed('shoot_right')
	return ret


func _process(_delta):	
	if	startable && any_input():
		$start.play(0)
	elif startable && Input.is_action_just_pressed('ui_cancel'):
		global.music_fade()
		global.time_start = OS.get_ticks_msec()
		var _ret = get_tree().change_scene("res://world1.tscn")
	startable = true


func _on_start_finished():
	var _ret = get_tree().change_scene("res://intro1.tscn")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
