extends "res://gridObject.gd"

onready var grid = get_tree().get_root().get_node("world/YSort/grid")

enum DIRECTION {LEFT, UP, RIGHT, DOWN, NOT_YET}

export(DIRECTION) var state = DIRECTION.LEFT

const dir_vectors = [Vector2.LEFT, Vector2.UP, Vector2.RIGHT, Vector2.DOWN]

var frame = 0
var index = 0
var coordinates = Vector2(0,0)
var active = true
var in_dir = Vector2.LEFT
var out_dir = Vector2.LEFT
var frozen = false
var norm = Vector2.ZERO

var ancestor = null
var decendant = null

var to_break = false

var end_stage = false

var vinecable_anim = "LR"

export var hurtable = true

export var shot_through = false

onready var sprite = $pivot/AnimatedSprite

onready var wrapee = $pivot/wrapee
onready var head = $pivot/head
onready var activeSparkle = $pivot/activeSparkle
onready var vinecable = $pivot/vinecable

export var can_press = true

export var visible_cable = true

var debug_printing = false

var vinecable_frame = 0

var cloneID = null


func can_grab():
	pass

func set_night():
	modulate = Color('7e75cf')
	
func set_day():
	modulate = Color('ffffff')

func unmonitor():
	$pivot/breakbox.monitorable = false
	$pivot/breakbox.monitoring = false

func _enter_tree():
	var _tmp = global.connect("next_stage", self, "to_next_stage")

func to_next_stage():
	if end_stage:
		$pivot/AnimationPlayer.play("teleport2")

func set_decendant(obj):
	# for interface compatibility with vineshot
	self.decendant = obj
	print("decendent obj" + str(obj))
	if obj != null:
		self.out_dir = (obj.cell - cell).normalized()
	else:
		print("null dec")
		self.out_dir = dir_vectors[state]
	debug_printing = true
	update_cable()

func set_ancestor(obj):
	# for interface compatibility with vineshot
	self.ancestor = obj
	
	if obj != null:
		self.in_dir = (obj.cell- cell).normalized()
	else:
		self.in_dir = -dir_vectors[state]
	update_cable()

func set_state(s):
	state = s
	in_dir = -dir_vectors[s]
	out_dir = dir_vectors[s]

func update_cable():
	if debug_printing:
		print("out_dir in update_cable " + str(out_dir))
		print("in_dir in update_cable " + str(in_dir))
		debug_printing = false
	if in_dir == Vector2.LEFT:
		if out_dir == Vector2.RIGHT:
			vinecable_anim = "LR"
		elif out_dir == Vector2.DOWN:
			vinecable_anim = "DL"
		elif out_dir == Vector2.UP:
			vinecable_anim = "UL"
		elif out_dir == Vector2.LEFT:
			vinecable_anim = "LL"
	if in_dir == Vector2.RIGHT:
		if out_dir == Vector2.LEFT:
			vinecable_anim = "LR"
		elif out_dir == Vector2.DOWN:
			vinecable_anim = "DR"
		elif out_dir == Vector2.UP:
			vinecable_anim = "UR"
		elif out_dir == Vector2.RIGHT:
			vinecable_anim = "RR"
	if in_dir == Vector2.UP:
		if out_dir == Vector2.RIGHT:
			vinecable_anim = "UR"
		elif out_dir == Vector2.DOWN:
			vinecable_anim = "UD"
		elif out_dir == Vector2.LEFT:
			vinecable_anim = "UL"
		elif out_dir == Vector2.UP:
			vinecable_anim = "UU"
	if in_dir == Vector2.DOWN:
		if out_dir == Vector2.RIGHT:
			vinecable_anim = "DR"
		elif out_dir == Vector2.UP:
			vinecable_anim = "UD"
		elif out_dir == Vector2.LEFT:
			vinecable_anim = "DL"
		elif out_dir == Vector2.DOWN:
			vinecable_anim = "DD"
	#print(anim)
	#print(vinecable)
	if vinecable != null:
		vinecable.animation = vinecable_anim
		vinecable.playing = false
		vinecable.frame = vinecable_frame
		#vinecable.play(vinecable_anim)
		

# Called when the node enters the scene tree for the first time.
func _ready():
	type = CELL_TYPES.VINE
	material.set_shader_param("cutoff", 0.0)
	use_parent_material = false
	#in_dir = -dir_vectors[state]
	#out_dir = dir_vectors[state]
	$pivot/AnimationPlayer.play("RESET")
	if !visible_cable:
		vinecable.visible = false
		activeSparkle.visible = false
	else:
		vinecable.animation = vinecable_anim
		
	vinecable.frame = vinecable_frame
	vinecable.playing = false
	
	if state == DIRECTION.LEFT:
		sprite.animation = "left"
		head.animation = "left"
		head.position.x = -global.d
		norm = Vector2.LEFT


	elif state == DIRECTION.RIGHT:
		sprite.animation = "right"
		head.animation = "right"
		head.position.x = global.d
		norm = Vector2.RIGHT


	elif state == DIRECTION.UP:
		sprite.animation = "up"
		head.animation = "up"
		head.position.y = -global.d
		norm = Vector2.UP


	elif state == DIRECTION.DOWN:
		sprite.animation = "down"
		head.animation = "down"
		head.position.y = global.d
		norm = Vector2.DOWN
	
	head.frame = frame
	sprite.frame = frame
	play_animation()

func deactivate():
	active = false
	head.visible=false
	activeSparkle.visible = false
	if sprite.animation == "active":
		sprite.playing=false
	
func activate():
	active = true
	head.visible=true
	if index > 0:
		activeSparkle.visible = true
	if (sprite.frame == 4 and sprite.animation=='wrap') or (sprite.animation=="active" and sprite.playing==false):
		sprite.animation = "active"
		sprite.playing=true

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
		
#func move_to(next_cell):
#	#$AnimationPlayer.play("walk")
#	#var pos = global.get_world(next_cell)
#	var animlen =  global.seconds_per_move # $AnimationPlayer.current_animation_length
#	var move_direction = (next_cell - cell).normalized()
#
#	$Tween.interpolate_property($pivot, "position",  -move_direction * global.d, Vector2.ZERO, animlen, Tween.TRANS_LINEAR)
#	set_cell(next_cell)
#	$pivot.position = -move_direction * global.d

func play_animation():
	sprite.play()
	head.play()


func lower_index():
	#if not frozen:
	grid.set_cellv(cell,-1)
	if decendant != null:
		decendant.lower_index()
		decendant.set_ancestor(ancestor)
	else:
		activate()
	#print("MOVING")
	move(ancestor.cell, global.seconds_per_move)
	in_dir = ancestor.in_dir
	if !active:
		out_dir = ancestor.out_dir
	grid.set_cellv(cell,grid.VINE)
	index = index - 1
	
		#print("new index: " + str(index))
		
	#else:
		# all further decendants will 
		# call this
		# even if not frozen themselves
	#	lower_index_frozen()
		
func move_ancestor():
	if !ancestor.frozen:
		grid.set_cellv(ancestor.cell,-1)
		ancestor.move_to(cell)
		grid.set_cellv(cell,ancestor.type)
		ancestor.move_ancestor()
		
		
#func lower_index_frozen():
#	index = index - 1
#	if decendant != null:
#		decendant.lower_index_frozen()
#	else:
#		activate()

func uproot(delay):
	if delay > 0.0:
		$Timer.start(delay)
	else:
		actually_uproot()
		
func actually_uproot():
	$pivot/AnimationPlayer.play("uproot")

func break_object(_player_is_flying):
	#print("break vine")
	grid.set_cellv(cell,-1)
	
	
#	if !player_is_flying:
	if decendant != null:
		decendant.lower_index()
		decendant.set_ancestor(ancestor)
	elif active: # active check might be redundant
		#print("ACTIVE THIS IS BUG")
		# if vinecell have no decendants, you should be active
		if ancestor != null:
			if ancestor.type != grid.PLAYER:
				ancestor.activate()
				
			else:
				grid.clones[cloneID].add_grab_vector_from_state(state)
			
		else:
			print("This should not happen")
#	else:
#		if decendant != null:
#			decendant.lower_index_frozen()
#			decendant.ancestor = ancestor
#		elif active:
#			if ancestor != null:
#				if ancestor.type != grid.PLAYER:
#					ancestor.activate()
#
#				else:
#					grid.player.add_grab_vector_from_state(state)
#			else:
#				print("This should not happen")
#		move_ancestor()
			
	ancestor.set_decendant(decendant)
	var i = grid.vinecells.find(self)
	grid.vinecells.remove(i)
	to_break = false
	global.play_break()
	$pivot/AnimationPlayer.play("break")
	

func _on_breakbox_area_entered(area):
	if area.dangerous:
		if hurtable:
			if !(self in grid.breaking_children):
				#print("ancestor of object that will break "  + str(ancestor))
				grid.breaking_children.append(self)
				$pivot/AnimationPlayer.play('white')
			to_break = true
	if !shot_through:
		area.take_damage()
	
func hide_head(_direction):
	head.visible = false
	
func show_head():
	head.visible = true

func _on_Timer_timeout():
	actually_uproot()


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "break":
		queue_free()


func _on_AnimatedSprite_animation_finished():
	if sprite.animation == "wrap" and active:
		sprite.animation = "active"
	pass # Replace with function body.
