extends "res://gridObject.gd"

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var grid = get_tree().get_root().get_node("world/YSort/grid")

const grabable = false
const pushable = false
const autograb = false

var to_break = false

var hurtable = false

onready var sprite = $pivot/Sprite

# Called when the node enters the scene tree for the first time.
func _ready():
	type=CELL_TYPES.WALL
	sprite.visible=false
	#cell = grid.world_to_map(position)
	


	




func _on_Area2D_area_entered(area):
	area.take_damage()
