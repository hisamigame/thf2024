extends "res://gridObject.gd"

var bullet = preload('bullet.tscn')
# Declare member variables here. Examples:
# var a = 2
# var b = "text"rea
onready var grid = get_tree().get_root().get_node("world/YSort/grid")
onready var gate_grid = get_tree().get_root().get_node("world/YSort/gategrid")
#var bullet = preload('bullet.tscn')

enum {NORMAL, CHARGING, EXHAUSTED, FALLING}

enum {LEFT, UP, RIGHT, DOWN, NOT_YET}

var rot_states_vec = [Vector2.LEFT,Vector2.UP,Vector2.RIGHT,Vector2.DOWN]
var rot_states = [LEFT, UP, RIGHT, DOWN]

export var rot_state = 3

var state = NORMAL

var pushable = true
var grabable = true
var end_stage = false

var hurtable = true

var to_break = false
var can_press = true

onready var sprite = $pivot/AnimatedSprite
onready var exclaim = $pivot/exclaim

var timer = 0.0
var can_fall = true
export var rotateEvery = 1.0

export var rotate_dir = 1

export var bullet_speed = 50.0

# Called when the node enters the scene tree for the first time.

const sightblockTiles = [CELL_TYPES.OBSTACLE, CELL_TYPES.PLAYER, CELL_TYPES.VINE, CELL_TYPES.WALL, CELL_TYPES.GATE]

func _process(delta):
	match state:
		NORMAL:
			normal(delta)
		CHARGING:
			charging(delta)
		EXHAUSTED:
			exhausted(delta)

func charging(_delta):
	pass
	
func exhausted(_delta):
	pass
	
func set_night():
	modulate = Color('7e75cf')
	
func set_day():
	modulate = Color('ffffff')

func normal(_delta):
	# are we colliding?
	var collider = getCollider()
	if collider != null:
		if (collider.type == CELL_TYPES.PLAYER) or (collider.type == CELL_TYPES.VINE):
			to_charging()
			return
	spin(_delta)
	
func to_charging():
	exclaim.play("exclaim")
	$AnimationPlayer.play("charging")
	state = CHARGING
	
func to_exhausted():
	sprite.play("exhausted")
	var obj = bullet.instance()
	obj.speed = bullet_speed
	obj.direction = rot_state
	obj.position = position + rot_states_vec[rot_state] * global.d
	get_tree().get_current_scene().add_child(obj)
	# spawn bullet
	
func spin(delta):
	timer = timer + delta
	if timer > rotateEvery:
		rot_state = (rot_state + rotate_dir * 1) % 4
		timer = 0.0
		
		match rot_states[rot_state]:
			LEFT:
				sprite.play("left")
			RIGHT:
				sprite.play("right")
			UP:
				sprite.play("up")
			DOWN:
				sprite.play("down")

func getCollider():
	var i = 1
	var see_cell = cell
	var obj_id
	var obj_id2
	var obj
	
	match rot_states[rot_state]:
		LEFT:
			see_cell = see_cell + i*rot_states_vec[rot_state]
			obj_id2 = gate_grid.get_cellv(see_cell)
			obj_id = grid.get_cellv(see_cell)
			while !(obj_id in sightblockTiles) and (see_cell.x)>0 and obj_id2 ==-1:
				see_cell = see_cell + rot_states_vec[rot_state]
				obj_id = grid.get_cellv(see_cell)
				obj_id2 = gate_grid.get_cellv(see_cell)
			obj = grid.get_cell_of_type(see_cell, obj_id)
		RIGHT:
			see_cell = see_cell + rot_states_vec[rot_state]
			obj_id2 = gate_grid.get_cellv(see_cell)
			obj_id = grid.get_cellv(see_cell)
			while  !(obj_id in sightblockTiles)  and (see_cell.x)<(global.nx-1) and obj_id2 ==-1:
				see_cell = see_cell + i*rot_states_vec[rot_state]
				obj_id = grid.get_cellv(see_cell)
				obj_id2 = gate_grid.get_cellv(see_cell)
			obj = grid.get_cell_of_type(see_cell, obj_id)
		UP:
			see_cell = see_cell + rot_states_vec[rot_state]
			obj_id2 = gate_grid.get_cellv(see_cell)
			obj_id = grid.get_cellv(see_cell)
			while  !(obj_id in sightblockTiles) and (see_cell.y)>0 and obj_id2 ==-1:
				see_cell = see_cell + rot_states_vec[rot_state]
				obj_id = grid.get_cellv(see_cell)
				obj_id2 = gate_grid.get_cellv(see_cell)
			obj = grid.get_cell_of_type(see_cell, obj_id)
		DOWN:
			see_cell = see_cell + i*rot_states_vec[rot_state]
			obj_id2 = gate_grid.get_cellv(see_cell)
			obj_id = grid.get_cellv(see_cell)
			while  !(obj_id in sightblockTiles)  and (see_cell.y)<(global.ny-1) and obj_id2 ==-1:
				see_cell = see_cell + rot_states_vec[rot_state]
				obj_id = grid.get_cellv(see_cell)
				obj_id2 = gate_grid.get_cellv(see_cell)
			obj = grid.get_cell_of_type(see_cell, obj_id)
	return obj
	

func _ready():
	type = CELL_TYPES.OBSTACLE
	match rot_states[rot_state]:
			LEFT:
				sprite.play("left")
			RIGHT:
				sprite.play("right")
			UP:
				sprite.play("up")
			DOWN:
				sprite.play("down")

func current_sprite():
	var texture=sprite.get_sprite_frames().get_frame(sprite.animation,sprite.get_frame())
	return texture

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

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func break_object(_player_is_flying):
	# argument only here to satisfy interface
	print("break")
	queue_free()
	global.play_break()
	grid.set_cellv(cell,-1)
	to_break = false

func _on_breakbox_area_entered(area):
	if area.dangerous:
		if hurtable:
			to_break = true
			grid.breaking_children.append(self)
	area.take_damage()



func _on_AnimationPlayer_animation_finished(_anim_name):
	to_exhausted()

func fall():
	if can_fall:
		$Timer.start(global.seconds_per_move * 1.5)
		can_fall = false
		state = FALLING
		$AnimationPlayer.stop()
	
func actually_fall():
	sprite.z_index = -2
	global.play_fall()
	sprite.play("fall")
	

func _on_Timer_timeout():
	actually_fall()


func _on_AnimatedSprite_animation_finished():
	if sprite.animation == 'fall':
		queue_free()
