extends Node2D

enum CELL_TYPES {WALL=0, OBSTACLE, PLAYER, ACTOR, OBJECT, VINE, VINESHOOT, GATE}
export(CELL_TYPES) var type = CELL_TYPES.ACTOR

export(Vector2) var cell = Vector2.ZERO

var offset = Vector2.ZERO
var y_offset = 0
var position_should_be

#onready var grid = get_tree().get_current_scene().get_node("grid")
func set_cell(next_cell):
	cell = next_cell
	position = global.get_world(next_cell)
	
