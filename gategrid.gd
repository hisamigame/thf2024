extends TileMap


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	for child in get_children():
		var cell = world_to_map(child.position)
		set_cellv(cell, child.type)
		child.set_cell(cell)

func set_night():
	print('gategrid night')
	for child in get_children():
		if child.has_method('set_night'):
			child.set_night()

func set_day():
	for child in get_children():
		if child.has_method('set_day'):
			child.set_day()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
