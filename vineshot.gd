extends "res://gridObject.gd"

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var grid = get_tree().get_root().get_node("world/YSort/grid")

enum DIRECTION {LEFT, UP, RIGHT, DOWN, NOT_YET}

var spawn_x = 0
var spawn_y = 0

var wait_time = 0.0
var delay_seconds = global.seconds_per_move/2 # 5 frames

var current_cell = Vector2.ZERO
var next_cell = Vector2.ZERO

export(DIRECTION) var state = DIRECTION.NOT_YET

var direction = Vector2.ZERO

var index = -1

var active = true

var has_shoot = false

var progenitor = null

var to_resolve = false

var grabbed_obj = null

var ultimate_requester = null
var cloneID = null


func set_decendant(obj):
	var vinecell = get_parent().get_highest_index_vinecell(state, ultimate_requester.cloneID)
	#print(vinecell)
	vinecell.set_decendant(obj)
	
func set_state(s):
	state = s
	
func set_ancestor(obj):
	var vinecell = get_parent().get_highest_index_vinecell(state, ultimate_requester.cloneID)
	obj.set_ancestor(vinecell)

# Called when the node enters the scene tree for the first time.
func _ready():
	type = CELL_TYPES.VINESHOOT
	current_cell = grid.world_to_map(position)
	
	if state == DIRECTION.LEFT:
		direction = Vector2.LEFT
	elif state == DIRECTION.RIGHT:
		direction = Vector2.RIGHT
	elif state == DIRECTION.UP:
		direction = Vector2.UP
	elif state == DIRECTION.DOWN:
		direction = Vector2.DOWN
		
	$vineshot_cell.set_state(state)
	
func set_night():
	modulate = Color('7e75cf')
	
func set_day():
	# probably unused
	modulate = Color('ffffff')
	
func set_ultimate_requester(val):
	ultimate_requester = val
	cloneID = val.cloneID
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if to_resolve:
		if wait_time > delay_seconds:
			actually_resolve_shot()
		else:
			wait_time = wait_time + delta
	else:
		if wait_time > delay_seconds and !has_shoot:
			#deactivate()
			has_shoot = true
			grid.request_shoot(self, direction, ultimate_requester)
		else:
			wait_time = wait_time + delta

		
func resolve_shot(this_grabbed_obj):
	# merely starts a timer
	grabbed_obj = this_grabbed_obj
	to_resolve = true
	wait_time = 0.0

func sub_resolve():
	var successful_move = grid.request_move_player(ultimate_requester, direction)
	var finished
	if successful_move:
		move_up(position)
		# correct
		finished = true
	elif grid.any_unpushables:
		# correct
		finished = true
		grabbed_obj.uproot(0.0)
		grabbed_obj.frozen = false
		grid.hookshot_move(grabbed_obj, -direction)
	else:
		# loop again to correct for nomove
		# after delay seconds
		print("we looping")
		finished = false
		$Timer.start(delay_seconds)
	return finished

func actually_resolve_shot():
	var finished = true
	if grabbed_obj != null:
		if !grabbed_obj.frozen:
			# moves the grabbed object
			grid.hookshot_move(grabbed_obj, -direction)
		else:
			# moves the player assembly
			ultimate_requester.set_flying()
			finished = sub_resolve()
			
				
	#if !grid.any_unpushables:
	#	resolve_shot(grabbed_obj)
	#else:
	if finished:
		progenitor.resolve_shot(grabbed_obj)
		call_deferred("queue_free")
	
func move_up(new_pos):
	if progenitor.type == CELL_TYPES.VINESHOOT:
		progenitor.move_up(position)
	position = new_pos
		
func deactivate():
	#active = false
	get_parent().deactivate_vinecell(state, ultimate_requester.cloneID)


func _on_Timer_timeout():
	sub_resolve()
