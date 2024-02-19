extends "res://gridObject.gd"

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var grid = get_tree().get_root().get_node("world/YSort/grid")

const grabable = true
const pushable = false
const autograb = true

onready var sprite = $pivot/Sprite

export var hurtable = true

var to_break = false

var index = 1

var end_stage = false

# Called when the node enters the scene tree for the first time.
func _ready():
	type = CELL_TYPES.OBSTACLE
	cell = grid.world_to_map(position)
	
func set_night():
	modulate = Color('7e75cf')
	
func set_day():
	modulate = Color('ffffff')

func move(next_cell):
	if next_cell != null:
		move_to(next_cell)
		$Tween.start()
	else:
		bump()
		
func current_sprite():
	# for animated sprites, would return the current frame
	# return sprite.get_frame_texture(sprite.animation, sprite.frame)
	return sprite.texture
		
func bump():
	pass
	
	
func fall():
	visible = false
	queue_free()
		
		
func move_to(next_cell):
	#$AnimationPlayer.play("walk")
	var animlen =  global.seconds_per_move # $AnimationPlayer.current_animation_length
	var move_direction = (next_cell - cell).normalized()
	
	$Tween.interpolate_property($pivot, "position",  -move_direction * grid.d, Vector2.ZERO, animlen, Tween.TRANS_LINEAR)
	set_cell(next_cell)
	$pivot.position = -move_direction * grid.d

func break_object(_player_is_flying):
	# this should never be called
	print("this object should never break")
	global.play_break()
	queue_free()
	grid.set_cellv(cell,-1)
	to_break = false

func _on_breakbox_area_entered(area):
	area.take_damage()
	if hurtable:
		to_break = true
		grid.breaking_children.append(self)
