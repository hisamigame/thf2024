extends TextureRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var startable = false
onready var score_label = $score
var score = 0
# Called when the node enters the scene tree for the first time.

func any_input():
	return Input.is_action_just_pressed('ui_down') or Input.is_action_just_pressed('ui_up') or Input.is_action_just_pressed('ui_left') or Input.is_action_just_pressed('ui_right') or Input.is_action_just_pressed('shoot_down') or Input.is_action_just_pressed('shoot_up') or Input.is_action_just_pressed('shoot_left') or Input.is_action_just_pressed('shoot_right')

func any_input_pressed():
	return Input.is_action_pressed('ui_down') or Input.is_action_pressed('ui_up') or Input.is_action_pressed('ui_left') or Input.is_action_pressed('ui_right') or Input.is_action_pressed('shoot_down') or Input.is_action_pressed('shoot_up') or Input.is_action_pressed('shoot_left') or Input.is_action_pressed('shoot_right')


func _ready():
	score = global.load_lastscore()
	score_label.text = "Your time: " + str(score) + " s"

func _process(_delta):
	if	startable && any_input():
		var _ret = get_tree().change_scene("res://titleScreen.tscn")	
	startable = true
