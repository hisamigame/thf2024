extends TextureRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var startable = false


# Called when the node enters the scene tree for the first time.
var lapsed = 0
var maxchar = 1

onready var text = $CenterContainer/text
export var next_scene = "res://intro2.tscn"

export var quick_skip_scene = "res://world1.tscn"

export var message = "INTRO1"

func _enter_tree():
	var _tmp = global.connect("redo_scene", self, "reset")

func reset():
	var _unused = get_tree().change_scene("res://intro1.tscn")

func _ready():
	lapsed = 0.0
	text.text = tr(message)
	maxchar = len(text.text)
	text.visible_characters = 1

func update_maxchar():
	maxchar = len(text.text)

func any_input():
	return Input.is_action_just_pressed('ui_down') or Input.is_action_just_pressed('ui_up') or Input.is_action_just_pressed('ui_left') or Input.is_action_just_pressed('ui_right') or Input.is_action_just_pressed('shoot_down') or Input.is_action_just_pressed('shoot_up') or Input.is_action_just_pressed('shoot_left') or Input.is_action_just_pressed('shoot_right')

func any_input_pressed():
	return Input.is_action_pressed('ui_down') or Input.is_action_pressed('ui_up') or Input.is_action_pressed('ui_left') or Input.is_action_pressed('ui_right') or Input.is_action_pressed('shoot_down') or Input.is_action_pressed('shoot_up') or Input.is_action_pressed('shoot_left') or Input.is_action_pressed('shoot_right')


func _process(delta):
	if startable:
		if Input.is_action_just_pressed('ui_cancel'):
			global.music_fade()
			global.time_start = OS.get_ticks_msec()
			var _unused = get_tree().change_scene(quick_skip_scene)
		elif (text.visible_characters >= maxchar) && any_input():
			var _unused = get_tree().change_scene(next_scene)
		elif text.visible_characters<maxchar && any_input_pressed():
			lapsed += 10*delta
		elif text.visible_characters<maxchar:
			lapsed += delta
	else:
		lapsed += delta
	text.visible_characters = lapsed/0.1

	startable = true



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
