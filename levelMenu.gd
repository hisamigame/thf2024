extends ColorRect


# based on
# https://youtu.be/p_m3xgWAFo0?feature=shared

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var container1 = $GridContainer/VBoxContainer1
onready var container2 = $GridContainer/VBoxContainer2

export var i_default_focus = 0

var difficulty = 'Normal'

var menu_items
var N
var current_focus : Node = null
var i_current_focus = 0 # not implemented yet
var previous_menu : Node = null

onready var sprite#: AnimatedSprite = $Sprite


signal item_selected (item)

func get_menu_items():
	var items = []
	for child in container1.get_children():
		if not child is Control:
			continue
		if not child.visible:
			continue
		items.append(child)
	for child in container2.get_children():
		if not child is Control:
			continue
		if not child.visible:
			continue
		items.append(child)
	return items

func move_cursor(i):
	var offset
	if i < 10:
		offset = container1.rect_position.x
	else:
		offset = container2.rect_position.x
	$Sprite.position.x = menu_items[i].rect_position.x  + offset
	$Sprite.position.y = menu_items[i].rect_position.y + menu_items[i].rect_size.y * 0.5


func set_focus():
	menu_items[i_default_focus].grab_focus()
	move_cursor(i_default_focus)
	
	
	

func set_level_titles():
	var labels = []
	var n
	var Nvisible
	match difficulty:
		"Normal":
			n = 20
			for i in range(n):
				labels.append("WORLD" + str(i+1) + "_0")
			if global.highest_seen_level >= 20:
				Nvisible = 20
			else:
				Nvisible = global.highest_seen_level
		"Hard":
			n = 20
			for i in range(n):
				labels.append("WORLD" + str(i+101) + "_0")
			if global.highest_seen_level >= 120:
				Nvisible = 20
			else:
				Nvisible = global.highest_seen_level - 100
		"Lunatic":
			n = 20
			for i in range(n):
				labels.append("WORLD" + str(i+201) + "_0")
			if global.highest_seen_level >= 220:
				Nvisible = 20
			else:
				Nvisible = global.highest_seen_level - 200
				
	for i in range(n):
		menu_items[i].text = labels[i]
		if i >= Nvisible:
			menu_items[i].visible=false

func configure_focus():
	var iprev
	var inext
	var inext2
	var iprev2
	for i in N:
		iprev = (i - 1) % N
		inext = (i + 1) % N
		iprev2 = (i - 10) % N
		inext2 = (i + 10) % N
		menu_items[i].focus_neighbour_bottom = menu_items[inext].get_path()
		menu_items[i].focus_neighbour_top = menu_items[iprev].get_path()
		menu_items[i].focus_neighbour_right = menu_items[inext2].get_path()
		menu_items[i].focus_neighbour_left = menu_items[iprev2].get_path()
		
		
func _unhandled_key_input(event):
	# we block input
	if visible:
		get_viewport().set_input_as_handled()
		if event.is_action_pressed("ui_accept"):
			emit_signal('item_selected', current_focus)
		elif event.is_action_pressed("ui_cancel"):
			visible = false
			if previous_menu:
				previous_menu.set_focus()
			

# Called when the node enters the scene tree for the first time.
func _ready():
	sprite = $Sprite
	menu_items = get_menu_items()
	N = len(menu_items)
	configure_focus()
	var _tmp = get_viewport().connect('gui_focus_changed', self, '_on_focus_changed')
	

func _on_focus_changed(item):
	var offset
	if item in menu_items:
		sprite.visible = true
		i_current_focus = menu_items.find(item)
		i_default_focus = i_current_focus # remember choices
		move_cursor(i_current_focus)
		current_focus = item
	else:
		sprite.visible = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
