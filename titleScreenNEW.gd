extends TextureRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var startable = false

onready var hiscore_label = $CenterContainer/Label
# Called when the node enters the scene tree for the first time.

# MENU STATE
var top_menu_choice = null
var difficulty_menu_choice = null

func _ready():
	global.read_from_save()
	var arr = global.load_hiscores()
	if !(len(arr) == 0 or (len(arr)==1 and arr[0] == 0)):
		var hiscore = arr.min()
	
	global.start_music()
	global.pause_music()
	global.play_title()
	# to reset the state between games
	# we have to set the global variables to default
	# since the singleton otherwise will remember
	# and we have to always return to the title screen between games.
	global.deaths = 0
	global.spause = false
	global.message = "Ready?"
	global.movementPressOrder = [0]
	global.new_level = false
	$difficultyMenu.unlock_difficulties()
	$difficultyMenu.previous_menu = $mainMenu
	if global.difficulty_unlocked > 0:
		$levelMenu.previous_menu = $difficultyMenu
	else:
		$levelMenu.previous_menu = $mainMenu
	if global.stage == 1:
		$mainMenu.hide_cont()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
#func any_input():
#	var ret = Input.is_action_just_pressed('ui_down') or Input.is_action_just_pressed('ui_up') or Input.is_action_just_pressed('ui_left') or Input.is_action_just_pressed('ui_right') or Input.is_action_just_pressed('shoot_down') or Input.is_action_just_pressed('shoot_up') or Input.is_action_just_pressed('shoot_left') or Input.is_action_just_pressed('shoot_right') or Input.is_action_just_pressed('ui_accept')
#	return ret


func _unhandled_key_input(event):
	if event.is_action_pressed("ui_accept") and startable:
		$mainMenu.visible = true
		$mainMenu.set_focus()
		$mainMenu.move_cursor($mainMenu.i_current_focus)
		startable = false
		set_process(true)

func _process(_delta):
	startable = true
	set_process(false)



func _on_start_finished():
	if global.stage > 1:
		global.music_fade()
		global.time_start = OS.get_ticks_msec()
		var _ret = get_tree().change_scene(global.current_level())
	else:
		var _ret = get_tree().change_scene("res://intro1.tscn")


func _on_mainMenu_item_selected(item):
	top_menu_choice = item.text
	match top_menu_choice:
		'New Game':
			if global.difficulty_unlocked > 0:
				$difficultyMenu.visible = true
				$difficultyMenu.set_focus()
			else:
				global.stage = 1
				$start.play()
		'Select level':
			if global.difficulty_unlocked > 0:
				$difficultyMenu.visible = true
				$difficultyMenu.set_focus()
			else:
				$levelMenu.set_level_titles()
				$levelMenu.visible = true
				$levelMenu.set_focus()
		'Continue':
			$start.play() 
		'Gallery':
			# TODO show gallery menu
			pass


func _on_difficultyMenu_item_selected(item):
	difficulty_menu_choice = item.text
	if top_menu_choice == 'New Game':
		match difficulty_menu_choice:
			'Normal':
				global.stage = 1
			'Hard':
				global.stage = 101
			'Lunatic':
				global.stage = 201
				
		$start.play()
	elif top_menu_choice == 'Select level':
		# TODO show level select with right difficulty
		$levelMenu.difficulty = difficulty_menu_choice
		$levelMenu.set_level_titles()
		$levelMenu.visible = true
		$levelMenu.set_focus()


func _on_levelMenu_item_selected(item):
	var level = item.text.split('_')[0].substr(5)
	global.music_fade()
	global.time_start = OS.get_ticks_msec()
	var _ret = get_tree().change_scene("res://world" + level + ".tscn")
	
	
