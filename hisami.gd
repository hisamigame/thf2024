extends "res://gridObject.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var grid = get_parent()#get_tree().get_root().get_node("world/YSort/grid")

enum {LEFT, UP, RIGHT, DOWN, NOT_YET}

enum {NORMAL, SHOOTING, PULLING, PULLED, FALL, DEAD, WINNING} # states

export var cloneID = 0
export var startflip = false

const stateL = LEFT
const stateR = RIGHT
const stateU = UP
const stateD = DOWN

var state = NORMAL

var frameL = 0
var frameR = 1
var frameD = 2
var frameU = 3


var index = 0

var wait_seconds = 0.0
var break_wait_seconds = 0.0
var tomove = true
var tobreak = false
var shoot_direction =Vector2.ZERO

var inputs = [Vector2.ZERO]
var lastmove = Vector2.ZERO # for undo purposes
var actual_lastmove = Vector2.ZERO
var successful_move = false

var input_direction = Vector2.ZERO

onready var base_pivot = Vector2(0,-8)
onready var sprite = $pivot/sprite

var grab_vectors = [Vector2.DOWN, Vector2.UP, Vector2.RIGHT, Vector2.LEFT]

var to_break = false

var hidden_head = null

var flying = false

var hanging = false

const frozen = false

var change_level = false

var hurtable

var can_enter_hole = false




func _enter_tree():
	var _tmp = global.connect("next_stage", self, "to_next_stage")

# Called when the node enters the scene tree for the first time.

func to_next_stage():
	$AnimationPlayer.play("teleport")
	global.play_telep()
	state = WINNING
	
func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == 'teleport':
		global.actually_change_level()

func set_night():
	modulate = Color('7e75cf')
	
func set_day():
	modulate = Color('ffffff')

func _ready():
	y_offset = 8
	if startflip:
		$pivot/sprite.flip_h = true
	if cloneID != 0:
		can_enter_hole = true
		material.set_shader_param("flash_modifier", 0.8)
		material.set_shader_param("flash_color", Color(0.42,0.19,0.45, 0.1))
	else:
		can_enter_hole = false
		material.set_shader_param("flash_modifier", 0.0)
		material.set_shader_param("cutoff", 0.0)
	type = CELL_TYPES.PLAYER
	$AnimationPlayer.play("RESET")
	
	$pivot/vinecellL.frame = frameL
	$pivot/vinecellR.frame = frameR
	$pivot/vinecellD.frame = frameD
	$pivot/vinecellU.frame = frameU
	
	$pivot/vinecellL.state = LEFT
	$pivot/vinecellR.state = RIGHT
	$pivot/vinecellD.state = DOWN
	$pivot/vinecellU.state = UP
	
	$pivot/vinecellL.play_animation()
	$pivot/vinecellR.play_animation()
	$pivot/vinecellU.play_animation()
	$pivot/vinecellD.play_animation()

	$pivot/vinecellL.unmonitor()
	$pivot/vinecellR.unmonitor()
	$pivot/vinecellU.unmonitor()
	$pivot/vinecellD.unmonitor()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _process(delta):
	
	if state == NORMAL:
		
		if change_level:
			global.change_level()
			change_level = false
		
		# GHETO solution to what happens when blocks gets destroyed
		# mid-pull
		if tobreak:
			tobreak = false
			grid.break_objects()
		else:
			break_wait_seconds = break_wait_seconds + delta
			if break_wait_seconds >= global.seconds_per_move:
				tobreak = true
		
		
		if tomove:
			# shooting is on the same
			# timer as moving
			tomove = false
			if Input.is_action_pressed("shoot_up"):
				shoot_direction = Vector2.UP
				entering_shooting_state()
			elif Input.is_action_pressed("shoot_down"):
				shoot_direction = Vector2.DOWN
				entering_shooting_state()
			elif Input.is_action_pressed("shoot_left"):
				shoot_direction = Vector2.LEFT
				entering_shooting_state()
			elif Input.is_action_pressed("shoot_right"):
				shoot_direction = Vector2.RIGHT
				entering_shooting_state()
			elif !hanging:
				movement()
			else:
				sprite.play("idle")
		else:
			wait_seconds = wait_seconds + delta
			if wait_seconds >= global.seconds_per_move:
				tomove = true
			
					
	if state == SHOOTING:
		sprite.play("idle")
	elif state == PULLING:
		sprite.play("idle")
	elif state == PULLED:
		sprite.play("idle")
	global.update_gate(delta)
	
		
func entering_shooting_state():
	state = SHOOTING
	hide_head(shoot_direction)
	grid.get_highest_index_vinecell(vector2state(shoot_direction), cloneID).hide_head(shoot_direction)
	grid.request_shoot(self, shoot_direction, self)
	
	
	
func hide_head(direction):
	#print("hide head " + str( direction))
	if direction == Vector2.DOWN:
		hidden_head = $pivot/vinecellD
	elif direction == Vector2.UP:
		hidden_head = $pivot/vinecellU
	elif direction == Vector2.RIGHT:
		hidden_head = $pivot/vinecellR
	elif direction == Vector2.LEFT:
		hidden_head = $pivot/vinecellL
	hidden_head.head.visible = false
	
func show_head():
	if hidden_head.active:
		hidden_head.head.visible = true
		
func end_shooting_state(hit_object):
	if hit_object.grabable:
		if hit_object.pushable:
			state = PULLING
		else:
			state = PULLED
	else:
		state = PULLING
		# we are pulling nothing?
		# not sure if this needs a special state

func end_pull_state():
	#if state != FALL:
	state = NORMAL
	print("END PULLED STATE")
	show_head()
	grid.get_highest_index_vinecell(vector2state(shoot_direction), cloneID).show_head()
		
	grid.special_break = true
	unset_flying()
	if grid.check_hole(cell):
		fall()
	grid.unfreeze_all()
	shoot_direction = Vector2.ZERO
	
		
func set_flying():
	flying = true
	
func unset_flying():
	flying = false
	
func fall():
	state = FALL
	$Timer.start(global.seconds_per_move)
	
func actually_fall():
	sprite.animation="fall"
	global.play_delayed_fall()
	if cloneID == 0:
		global.show_reset()

func update_look_direction(direction):
	if direction.x > 0:
		$pivot/sprite.flip_h = true
	elif direction.x < 0:
		$pivot/sprite.flip_h = false

func get_inputs():	
	var ninputs = len(global.movementPressOrder)
	if ninputs > 1:
		inputs = global.movementPressOrder
	else:
		inputs = global.thisTickMovementPressOrder
	return inputs

func movement():
	successful_move = false
	inputs = get_inputs()
	input_direction = inputs[-1]
	
	if input_direction != Vector2.ZERO:
		sprite.play("walk")
		update_look_direction(input_direction)
		grid.request_move_player(self, input_direction)
	else:
		sprite.play("idle")
	
func start_move_timer():
	tomove = false
	wait_seconds = 0.0
	global.thisTickMovementPressOrder = [Vector2.ZERO]
	
func move(next_cell, animlen):
	if next_cell != null:
		move_to(next_cell, animlen)
		#$Tween.start()
	else:
		bump()
	
		
func move_to(next_cell, animlen =  global.seconds_per_move):
	#$AnimationPlayer.play("walk")
	#var move_direction = (next_cell - cell).normalized()
	
	#print(next_cell)
	cell = next_cell
	position_should_be = global.get_world(next_cell) - Vector2(0,y_offset)
	#$Tween.interpolate_property($pivot, "position", base_pivot -move_direction * grid.d, base_pivot, animlen, Tween.TRANS_LINEAR)
	$Tween.interpolate_property(self, "position", position, position_should_be, animlen, Tween.TRANS_LINEAR)
	
	#print("moved to " + str(cell))
	#$pivot.position = base_pivot -move_direction * grid.d
	$Tween.start()
	
	#yield($AnimationPlayer,"animation_finished")
	
	
func resolve_shot(grabbed_obj):
	if grabbed_obj:
		if grabbed_obj.frozen:
			grabbed_obj.uproot(global.seconds_per_move)
	end_pull_state()
	start_move_timer()
	
	
func remove_grab_vector(direction):
	var i = grab_vectors.find(direction)
	grab_vectors.remove(i)
	
	if direction == Vector2.DOWN:
		$pivot/vinecellD.deactivate()
	elif direction == Vector2.UP:
		$pivot/vinecellU.deactivate()
	elif direction == Vector2.RIGHT:
		$pivot/vinecellR.deactivate()
	elif direction == Vector2.LEFT:
		$pivot/vinecellL.deactivate()
		
func add_grab_vector(direction):
	var i = grab_vectors.find(direction)
	if i == -1:
		grab_vectors.append(direction)
		if direction == Vector2.DOWN:
			$pivot/vinecellD.activate()
		elif direction == Vector2.UP:
			$pivot/vinecellU.activate()
		elif direction == Vector2.RIGHT:
			$pivot/vinecellR.activate()
		elif direction == Vector2.LEFT:
			$pivot/vinecellL.activate()
	
		
func remove_grab_vector_from_state(s):
	var direction
	if s == UP:
		direction = Vector2.UP
	elif s == DOWN:
		direction = Vector2.DOWN
	elif s == LEFT:
		direction = Vector2.LEFT
	elif s == RIGHT:
		direction = Vector2.RIGHT
	remove_grab_vector(direction)
	
		
func add_grab_vector_from_state(s):
	var direction
	if s == UP:
		direction = Vector2.UP
	elif s == DOWN:
		direction = Vector2.DOWN
	elif s == LEFT:
		direction = Vector2.LEFT
	elif s == RIGHT:
		direction = Vector2.RIGHT
	
	add_grab_vector(direction)
	

func vector2state(direction):
	var ret
	if direction == Vector2.DOWN:
		ret = DOWN
	elif direction == Vector2.UP:
		ret = UP
	elif direction == Vector2.RIGHT:
		ret = RIGHT
	elif direction == Vector2.LEFT:
		ret = LEFT
	return ret

func bump():
	sprite.play("idle")
	
func deactivate():
	# merely to satisfy interface
	pass
	
func set_decendant(_obj):
	print("hisami set decendant")
	# merely to satisfy interface
	pass	

func move_ancestor():
	# merely to satisfy interface
	pass

func push_object(push_velocity, collider):
	if collider.is_in_group('Pushable'):
		collider.push(push_velocity)


func break_object(_unused):
	print("death")
	state = DEAD
	global.play_hurt()
	to_break = false
	sprite.play("dead")
	if cloneID == 0:
		global.show_reset()
		global.deaths = global.deaths + 1

func _on_hurtbox_area_entered(area):
	if area.dangerous:
		if hurtable:
			if !(self in grid.breaking_children):
				#print("ancestor of object that will break "  + str(ancestor))
				grid.breaking_children.append(self)
			hurtable = false
		to_break = true
		grid.breaking_children.append(self)
	area.take_damage()


func _on_Timer_timeout():
	actually_fall()


