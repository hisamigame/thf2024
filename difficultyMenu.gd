extends "res://menu.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

enum {NORMAL, HARD, LUNATIC}
var selected_difficulty = NORMAL
enum {START, SELECT}
var next_menu = null


func unlock_difficulties():
	if global.difficulty_unlocked > 0:
		$HBoxContainer/Hard.visible = true
	if global.difficulty_unlocked > 1:
		$HBoxContainer/Lunatic.visible = true
	menu_items = get_menu_items()
	N = len(menu_items)
	configure_focus()
