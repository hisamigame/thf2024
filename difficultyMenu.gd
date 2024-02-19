extends "res://menu.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

enum {NORMAL, HARD, LUNATIC}
var selected_difficulty = NORMAL
enum {START, SELECT}
var next_menu = null



func set_focus():
	if global.difficulty_unlocked == 0:
		emit_signal('item_selected', $HBoxContainer/Normal)
	else:
		print('focusing difficult')
		menu_items[i_default_focus].grab_focus()

func unlock_difficulties():
	if global.difficulty_unlocked > 0:
		$HBoxContainer/Hard.visible = true
		print("Hard unlocked")
	if global.difficulty_unlocked > 1:
		$HBoxContainer/Lunatic.visible = true
	menu_items = get_menu_items()
	N = len(menu_items)
	configure_focus()

func _ready():
	sprite = $Sprite
	# for testing
	#global.difficulty_unlocked = 2
	#unlock_difficulties()
	#set_focus()
