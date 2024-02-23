extends TextureRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var startable = false


# Called when the node enters the scene tree for the first time.
var lapsed = 0
var maxchar = 1

export var next_scene = "res://Ending2.tscn"

export var quick_skip_scene = "res://Ending2.tscn"


func unlock_difficulty():
	if global.difficulty_unlocked < 1:
		global.difficulty_unlocked = 1
		global.write_to_save()

func _ready():
	var completiontime
	if global.time_start == null:
		completiontime = INF
	else:
		completiontime = (OS.get_ticks_msec() - global.time_start)/1000.0
	global.save_score(completiontime)
	unlock_difficulty()

func any_input():
	return Input.is_action_just_pressed('ui_accept') or Input.is_action_just_pressed('ui_down') or Input.is_action_just_pressed('ui_up') or Input.is_action_just_pressed('ui_left') or Input.is_action_just_pressed('ui_right') or Input.is_action_just_pressed('shoot_down') or Input.is_action_just_pressed('shoot_up') or Input.is_action_just_pressed('shoot_left') or Input.is_action_just_pressed('shoot_right')

func any_input_pressed():
	return Input.is_action_pressed('ui_accept') or Input.is_action_pressed('ui_down') or Input.is_action_pressed('ui_up') or Input.is_action_pressed('ui_left') or Input.is_action_pressed('ui_right') or Input.is_action_pressed('shoot_down') or Input.is_action_pressed('shoot_up') or Input.is_action_pressed('shoot_left') or Input.is_action_pressed('shoot_right')


func _process(_delta):
	if startable && any_input():
		var _unused = get_tree().change_scene(next_scene)


	startable = true
