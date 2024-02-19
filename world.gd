extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.

enum FLAVORS {MOKOU, KAGUYA}
enum NIGHT {DAY, NIGHT}

export(FLAVORS) var flavor = FLAVORS.MOKOU
export(NIGHT) var daytime = NIGHT.DAY

export var message = "Ready? Level 0"


var button_array = []

func set_night():
	$YSort/grid.set_night()
	var new_texture = load("res://floorsnight.png")
	$floorgrid.tile_set.tile_set_texture(0, new_texture)
	for child in get_children():
		if child.has_method('set_night'):
			child.set_night()
	
func set_day():
	$YSort/grid.set_day()
	var new_texture = load("res://floors.png")
	$floorgrid.tile_set.tile_set_texture(0, new_texture)
	for child in get_children():
		if child.has_method('set_day'):
			child.set_day()

func _ready():
	global.stage = int(get_tree().current_scene.filename.split('.')[0].split('world')[-1])
	if global.stage > global.highest_seen_level:
		global.highest_seen_level = global.stage
	global.write_to_save()
	global.unpause_music()
	global.softpause()
	#$UI.flavor = flavor
	if !global.bgmusic_playing():
		global.music_fade()
	global.update_flavor(flavor)
	var goal = get_node_or_null('YSort/grid/goal')
	if goal:
		goal.flavor = flavor
		goal.update_sprite()
	$UI.update_texture(global.past_flavor)
	global.message = message
	$UI.update_message()
	
	if daytime == NIGHT.NIGHT:
		set_night()
		for child in $YSort.get_children():
			if child.has_method('set_night'):
				child.set_night()
	elif daytime == NIGHT.DAY:
		set_day()
		for child in $YSort.get_children():
			if child.has_method('set_day'):
				child.set_day()
		
	
	var i = 0
	for child in get_children():
		if child.is_in_group('button'):
			child.id = i
			button_array.append(child)
			i = i + 1
	#$grid.set_gate_arrays(i)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("reset"):
		self.reset_level()
		
func reset_level():
	var _unused = get_tree().change_scene(global.current_level())


func _on_detection_area_exited(_area):
	pass # Replace with function body.
