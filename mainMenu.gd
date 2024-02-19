extends "res://menu.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func hide_cont():
	$HBoxContainer/Label2.visible = false
	menu_items = get_menu_items()
	i_default_focus = 0
	move_cursor(i_default_focus)

# Called when the node enters the scene tree for the first time.
#func _ready():
#	sprite = $Sprite


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
