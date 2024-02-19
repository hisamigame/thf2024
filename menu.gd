extends ColorRect


# based on
# https://youtu.be/p_m3xgWAFo0?feature=shared

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var container = $HBoxContainer

export var i_default_focus = 0

var menu_items
var N
var current_focus : Node = null
var i_current_focus = 0 # not implemented yet
var previous_menu : Node = null

onready var sprite#: AnimatedSprite = $Sprite


signal item_selected (item)

func get_menu_items():
	var items = []
	for child in container.get_children():
		if not child is Control:
			continue
		if not child.visible:
			continue
		items.append(child)
	return items
	

func move_cursor(i):
	var offset = container.rect_position.x
	sprite.position.x = menu_items[i].rect_position.x + offset - 8
	#print(str(i) + ":" + str(sprite.position.x))

func set_focus():
	menu_items[i_default_focus].grab_focus()
	move_cursor(i_default_focus)

func configure_focus():
	var iprev
	var inext
	for i in N:
		iprev = (i - 1) % N
		inext = (i + 1) % N
		menu_items[i].focus_neighbour_left = menu_items[iprev].get_path()
		menu_items[i].focus_neighbour_right = menu_items[inext].get_path()
		
		
		
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
	if item in menu_items:
		sprite.visible = true
		current_focus = item
		i_current_focus = menu_items.find(item)
		i_default_focus = i_current_focus # remember choices
		move_cursor(i_current_focus)
	else:
		sprite.visible = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
