extends "res://gridObject.gd"

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var grid = get_tree().get_root().get_node("world/YSort/grid")

const grabable = true
const pushable = true
const autograb = true

onready var sprite = $pivot/Sprite

export var hurtable = true

var to_break = false

var index = 1

var end_stage = false

var can_fall = true

var can_press = true

# Called when the node enters the scene tree for the first time.
func _ready():
	type = CELL_TYPES.OBSTACLE
	cell = grid.world_to_map(position)
	

func set_night():
	modulate = Color('7e75cf')
	
func set_day():
	modulate = Color('ffffff')

func move(next_cell, animlen):
	if next_cell != null:
		move_to(next_cell, animlen)
		$Tween.start()
	else:
		bump()
		
func bump():
	pass
		
		
func move_to(next_cell, animlen):
	#print(next_cell)
	cell = next_cell
	position_should_be = global.get_world(next_cell) - Vector2(0,y_offset)
	#$Tween.interpolate_property($pivot, "position", base_pivot -move_direction * grid.d, base_pivot, animlen, Tween.TRANS_LINEAR)
	$Tween.interpolate_property(self, "position", position, position_should_be, animlen, Tween.TRANS_LINEAR)
	
	#print("moved to " + str(cell))
	#$pivot.position = base_pivot -move_direction * grid.d
	$Tween.start()

func current_sprite():
	# for animated sprites, would return the current frame
	# return sprite.get_frame_texture(sprite.animation, sprite.frame)
	var texture=sprite.get_sprite_frames().get_frame(sprite.animation,sprite.get_frame())
	return texture


func break_object(_player_is_flying):
	# argument only here to satisfy interface
	global.play_break()
	$pivot/AnimationPlayer.play("break")
	#queue_free()
	grid.set_cellv(cell,-1)
	to_break = false

func _on_breakbox_area_entered(area):
	if area.dangerous:
		if hurtable:
			to_break = true
			grid.breaking_children.append(self)
	area.take_damage()
	
func fall():
	if can_fall:
		$Timer.start(global.seconds_per_move * 1.5)
		can_fall = false
	
func actually_fall():
	sprite.z_index = -2
	global.play_fall()
	sprite.play("fall")
	

func _on_Sprite_animation_finished():
	if sprite.animation == 'fall':
		queue_free()

func _on_Timer_timeout():
	actually_fall()


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "break":
		queue_free()
