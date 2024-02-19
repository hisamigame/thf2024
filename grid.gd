extends TileMap


enum {WALL=0, OBSTACLE, PLAYER, ACTOR, OBJECT, VINE, VINESHOOT, GATE}

enum DIRECTION {LEFT, UP, RIGHT, DOWN, NOT_YET}

enum {NORMAL, SHOOTING, PULLING, PULLED, FALL, DEAD, WINNING} # player states
enum NIGHT {DAY, NIGHT}
var daytime = NIGHT.DAY

#const d = 16
onready var d = cell_size
onready var x0 = position.x
onready var y0 = position.y

#onready var hole_grid = get_parent().get_node("holegrid")
onready var hole_grid = get_tree().get_root().get_node("world/holegrid")
onready var gate_grid = get_parent().get_node("gategrid")

#onready var player = $hisami
var clones = [null, null, null, null] # make longer if needed


const Vinecell = preload('res://vinecell.tscn')
const Vineshot = preload('res://vineshot.tscn')
const wall = preload('res://wall.tscn')

var wait_seconds = 0.0
var tomove = true

var down_index = 0
var up_index = 0
var right_index = 0
var left_index = 0

var vinecells = []

var breaking_children = []

var special_break = false

var any_unpushables = false

var all_movers = []
var all_endcells = []
var all_startcells = []
var all_canmove = []
var all_flying = []
var all_direction = []

var goal

func set_gate_arrays(n):
	for child in get_children():
		if child.is_in_group('gate'):
			child.set_button_array(n)

# Called when the node enters the scene tree for the first time.
func spawn_walls():
	for cell in get_used_cells_by_id(WALL):
		var wallobj = wall.instance()
		var pos = map_to_world(cell) + global.d * Vector2.ONE/2
		wallobj.position = pos
		wallobj.cell = cell
		#get_tree().get_current_scene().add_child(wallobj)
		call_deferred("add_child", wallobj)

func _ready():
	goal = get_node_or_null('goal')
	spawn_walls()
	#print("wall id " + str(WALL))
	
	for child in get_children():
		var cell = world_to_map(child.position)
		#print(cell)
		set_cellv(cell, child.type)
		child.set_cell(cell)
		#child.move(cell)
		if child.type == PLAYER:
			clones[child.cloneID] = child
			child.position.y = child.position.y - child.y_offset
	#goal.position.y = goal.position.y - goal.y_offset

func get_highest_index_vinecell(state, cloneID):
	var highest_index = 0
	#var ret = player
	var ret = clones[cloneID]
	
	# not sure if copy needed
	var current_vinecells = [] + vinecells # to copy
	
	for vinecell in current_vinecells:
		if vinecell.cloneID == cloneID:
			if vinecell.state == state:
				if vinecell.index > highest_index:
					highest_index = vinecell.index
					ret = vinecell
	return ret
		

func set_night():
	var new_texture = load("res://wallsnight.png")
	tile_set.tile_set_texture(0, new_texture)
	daytime = NIGHT.NIGHT
	for child in get_children():
		if child.has_method('set_night'):
			child.set_night()

func set_day():
	var new_texture = load("res://template-export.png")
	tile_set.tile_set_texture(0, new_texture)
	daytime = NIGHT.DAY
	for child in get_children():
		if child.has_method('set_day'):
			child.set_day()

func request_shoot(requester, direction, ultimate_requester):
	any_unpushables = false
	
	var state = DIRECTION.NOT_YET
	if direction == Vector2.LEFT:
		state = DIRECTION.LEFT
	elif direction == Vector2.RIGHT:
		state = DIRECTION.RIGHT
	elif direction == Vector2.UP:
		state = DIRECTION.UP
	elif direction == Vector2.DOWN:
		state = DIRECTION.DOWN
	
	var shooter
	if requester.type == PLAYER:
		# if the player requested it
		# we should fire from the largest index vine with the right state
		shooter = get_highest_index_vinecell(state, ultimate_requester.cloneID)
		#shooter.head.visible = false
		#print(shooter)
	else:
		shooter = requester
	var spawn_shoot_cell = get_end_cell(shooter, direction)
	var spawn_cell_id = get_cellv(spawn_shoot_cell)
	var spawn_gate_cell_id = gate_grid.get_cellv(spawn_shoot_cell)
	if spawn_gate_cell_id != -1:
		requester.resolve_shot(null)
		return
	
	if (spawn_shoot_cell.x > (global.nx+1) or spawn_shoot_cell.x < 0 or spawn_shoot_cell.y > (global.ny + 1) or spawn_shoot_cell.y < 0):
		requester.resolve_shot(null)
		return
	
	if requester.type == PLAYER:
		pass
		#if clause to not spam debug output
		#print("gonna shoot")
		#print("shoot spawn cell id "  + str(spawn_cell_id))
		#print("shoot spawn cell " + str(spawn_shoot_cell))
		#print("direction " + str(direction))
		#print("tilemap cells " + str(get_used_cells()))

	match spawn_cell_id:
		-1:
			# sometimes when moving
			# the player's position isn't updated
			# so we let the player shoot through the player
			var shot = Vineshot.instance()
			if daytime == NIGHT.NIGHT:
				shot.set_night()
			shot.position = get_world(spawn_shoot_cell)
			#shot.set_cell(spawn_shoot_cell)
			shot.set_cell(spawn_shoot_cell)
			shot.state = state
			shot.index = shooter.index
			shot.progenitor = requester
			shot.set_ultimate_requester(ultimate_requester)
			call_deferred('add_child',shot)
			
		ACTOR, OBSTACLE, OBJECT, WALL, GATE:
			# even objects can be hit
			var obj = get_cell_of_type(spawn_shoot_cell, spawn_cell_id)
			if obj.grabable:
				var new_vinecell = grab_object(obj, shooter, direction)
				requester.resolve_shot(new_vinecell)
				return 
			else:
				requester.resolve_shot(null)
				return
		VINE, PLAYER:
			requester.resolve_shot(null)
			return 
			#player.end_pull_state()
			#player.start_move_timer()
		
	#player.end_pull_state()
	#player.start_move_timer()
	
				
func check_hole(cell):
	return hole_grid.get_cellv(cell) != -1
		
		
func grab(mover, obj, direction, special=false):
	var did_grab = false
	if mover.type == PLAYER:
		if direction in mover.grab_vectors:
			var new_obj = grab_object(obj, mover, direction)
			if !obj.pushable:
				any_unpushables = true
			new_obj.frozen = false
			did_grab = true
								
	elif mover.type == VINE:
		if mover.active == true:
			var new_obj = grab_object(obj, mover, direction)
			did_grab = true
			new_obj.frozen = false
			if !obj.pushable:
				any_unpushables = true
	return did_grab
		
		
func get_movers_for_player(player):
	var movers = [player]
	# hookshot pegs are frozen as they are grabbed
	# until the player reaches them
	for vinecell in vinecells:
		if !vinecell.frozen and vinecell.cloneID == player.cloneID:
			movers.append(vinecell)
	return movers
			
func request_move_player(player, direction):
	#print(get_used_cells())
	#print(player.cell)
	#print(get_cellv(Vector2.ZERO))
	
	
	# this check might be redundant
	#if !player.flying:
	#	if check_hole(player.cell):
	#		player.fall()
	
	var end_cells = []
	var start_cells = []
	var to_push = []
	var end_cell_id
	var end_cell_id_gate
	var end_cell
	var start_cell
	var animlen
	if player.flying:
		animlen = global.seconds_per_move/2
	else:
		animlen = global.seconds_per_move

	var movers = get_movers_for_player(player)
	for mover in movers:
		start_cells.append(mover.cell)
		end_cells.append(get_end_cell(mover, direction))
	
	
	# by default, assume we can move and check for the opposite
	var can_move = true
	# check that we can move
	# first check for empty spaces and pushables/grabables
	for i in len(movers):
		end_cell = end_cells[i]
		end_cell_id = get_cellv(end_cell)
		end_cell_id_gate = gate_grid.get_cellv(end_cell)
		
		if end_cell_id_gate != -1:
			can_move = false
		
		if movers[i].type == PLAYER:
			if !movers[i].flying:
				# player cannot walk into holes, but can fly over them
				#end_cell_id2 = hole_grid.get_cellv(end_cell)
				if check_hole(end_cell):
					if !player.can_enter_hole:
						can_move = false
		
		match end_cell_id:
			-1:
				continue
			VINE:
				pass
				# UNUSED FEATURE
				var obj = get_cell_of_type(end_cell, end_cell_id)
				if obj != null:
					if obj.frozen:
						can_move = false
			OBJECT:
				# TODO: pick up object
				var obj = get_cell_of_type(end_cell, end_cell_id)
				print(obj)
			WALL:
				can_move = false
			ACTOR, OBSTACLE:
				var obj = get_cell_of_type(end_cell, end_cell_id)
				if not obj:
					pass
					#print(end_cell)
					#print(end_cell_id)
				if obj.grabable:
					# returns true if grabbed
					if grab(movers[i], obj, direction):
						can_move = false
						
				if can_move: # as a cheap check to see if didnt grabbed anything
					if obj.pushable:
						to_push.append(obj)
					else:
						can_move = false
						any_unpushables = true
	
	# if we can still move check if we can push all our pushables
	# appending to an array as we loop over it extends the loop
	# which we will use instead of a recursive function
	if can_move:
		for pushobj in to_push:
			end_cell = get_end_cell(pushobj, direction)
			end_cell_id = get_cellv(end_cell)
			
			end_cell_id_gate = gate_grid.get_cellv(end_cell)
			if end_cell_id_gate != -1:
				can_move = false
				any_unpushables = true
				break
			
			match end_cell_id:
				-1, VINE:
					continue
				OBJECT:
					# TODO: some objects might trigger something
					# if we push over them
					var obj = get_cell_of_type(end_cell, end_cell_id)
					print(obj)
				OBSTACLE, ACTOR, WALL, GATE:
					var obj = get_cell_of_type(end_cell, end_cell_id)
					if obj.pushable:
						to_push.append(obj)
					else:
						can_move = false
						any_unpushables = true
						break
						
	
	if can_move:
		for pushobj in to_push:
			start_cell = pushobj.cell #world_to_map(pushobj.position)
			end_cell = get_end_cell(pushobj, direction)
			# this will also include all grabobjects in to_grab
			movers.append(pushobj)
			start_cells.append(start_cell)
			end_cells.append(end_cell)
	
	# THIS IS WHERE MOVEMENT HAPPENS
	if can_move:
		var N = len(movers)
		for j in N:
			# first unset all initial positions
			# so we don't overwrite a new position
			set_cellv(start_cells[j], -1)
		for j in N:
			#v set all final positions safely
			movers[j].move(end_cells[j], animlen)
			# if the pushabel ended up over a hole
			if check_hole(end_cells[j]):
				if !((movers[j].type == VINE) or (movers[j].type == PLAYER and player.flying)):
					set_cellv(end_cells[j], -1)
					movers[j].fall()
				else:
					set_cellv(end_cells[j], movers[j].type)
			else:
				set_cellv(end_cells[j], movers[j].type)
				#if movers[j].type == PLAYER:
				#	movers[j].unfall()

	player.start_move_timer()
	return can_move
	#vinecell.move(end_pos)

func check_all_movers():
	var M = len(all_movers)
	var N1
	var N2
	var didgrab
	all_canmove = []
	# assume everything can move until proven otherwise
	for i in M:
		all_canmove.append(true)
	# ... and prove otherwise
	for i in M:
		for j in i+1:
			N1 = len(all_endcells[i])
			N2 = len(all_endcells[j])
			for k in N1:
				for l in N2:
					# got overlapping endcells
					if all_endcells[i][k] == all_endcells[j][l]:
						all_canmove[i] = false
						all_canmove[j] = false
						if all_canmove[i].type == PLAYER or (all_canmove[i].type == VINE):
							didgrab = grab(all_canmove[i], all_canmove[j], all_direction[i], true)
							if didgrab:
								all_canmove[i] = true
						elif all_canmove[j].type == PLAYER or (all_canmove[j].type == VINE):
							didgrab = grab(all_canmove[j], all_canmove[i], all_direction[j], true)
							if didgrab:
								all_canmove[j] = true

func actually_move():
	var M = len(all_movers)
	var N = 0
	for i in M:
		if all_canmove[i]:
			N = len(all_movers[i])
			# normal move
			for j in N:
				# first unset all initial positions
				# so we don't overwrite a new position
				set_cellv(all_startcells[i][j], -1)
			for j in N:
				#v set all final positions safely
				all_movers[i][j].move(all_endcells[i][j])
				# if the pushabel ended up over a hole
				if check_hole(all_endcells[i][j]):
					if !((all_movers[i][j].type == VINE) or (all_movers[i][j].type == PLAYER and all_flying[i])):
						set_cellv(all_endcells[i][j], -1)
						all_movers[i][j].fall()
					else:
						set_cellv(all_endcells[i][j], all_movers[i][j].type)
				else:
					set_cellv(all_endcells[i][j], all_movers[i][j].type)
		else:
			# objects bump
			pass

func hookshot_move(obj, direction):
	var end_cell = get_end_cell(obj, direction)
	var start_cell = obj.cell #world_to_map(obj.position)
	obj.move(end_cell, global.seconds_per_move/2)
	set_cellv(start_cell, -1)
	set_cellv(end_cell, obj.type)
	

func grab_object(grabobj, grabber, direction):
	
	var index = grabber.index
	var state = DIRECTION.NOT_YET
	
	var obj = Vinecell.instance()
	obj.cloneID = grabber.cloneID
	assert(obj.cloneID != null)
	obj.set_cell(grabobj.cell)
	if grabber.type != PLAYER:
		state = grabber.state
		grabber.deactivate()
		
	else:
		grabber.remove_grab_vector(direction)
		if direction == Vector2.UP:
			state = DIRECTION.UP
		elif direction  == Vector2.DOWN:
			state = DIRECTION.DOWN
		elif direction == Vector2.RIGHT:
			state = DIRECTION.RIGHT
		elif direction == Vector2.LEFT:
			state = DIRECTION.LEFT
	print("state in grab" + str(state))
	obj.set_state(state)
	obj.index = index + 1
	if daytime == NIGHT.NIGHT:
		obj.set_night()
	grabber.set_decendant(obj)
	
	
	
	
	if grabber.type != VINESHOOT:
		obj.set_ancestor(grabber)
	else:
		obj.set_ancestor(get_highest_index_vinecell(grabber.state, grabber.ultimate_requester.cloneID))
	
	print("ancestor asigned to grabbed object : " + str(obj.ancestor))
	print("index of newly grabbed object " + str(index))
	obj.type = VINE
	obj.position = grabobj.position
	#obj.cell = grabobj.cell
	
		
	#set_cellv(world_to_map(obj.position), VINE)
	set_cellv(obj.cell, VINE)
	add_child(obj)
	if direction == Vector2.DOWN:
		obj.sprite.flip_v = true
	elif direction == Vector2.RIGHT:
		obj.sprite.flip_h = true
	obj.sprite.animation = "wrap"
	obj.wrapee.texture = grabobj.current_sprite()
	obj.wrapee.offset = grabobj.offset
	# unused feature
	if !grabobj.pushable:
		obj.frozen = true
		if grabber.type != VINESHOOT:
			obj.uproot(0.0)
	#var end_cell = get_end_cell(obj, direction)
	vinecells.append(obj)
	grabobj.queue_free()
	
	obj.end_stage = grabobj.end_stage
	
	if grabobj.end_stage:
		if grabber.cloneID == 0:
			clones[0].change_level = true
	
	global.play_wrap()
	return obj
	
	

func get_cell_of_type(cell, type = OBSTACLE):
	for node in get_children():
		if node.type != type:
			continue
		#if world_to_map(node.position) == cell:
		if node.cell == cell:
			return node

func get_end_cell(entry, direction):
	var start_cell = entry.cell #world_to_map(entry.position)
	var end_cell = start_cell + direction
	return end_cell

func get_world(cell):
	return map_to_world(cell) + d/2
	
func deactivate_vinecell(state, cloneID):
	var vinecell = get_highest_index_vinecell(state, cloneID)
	if vinecell.type == VINE:
		vinecell.deactivate()
	elif vinecell.type == PLAYER:
		clones[cloneID].remove_grab_vector_from_state(state)

func mysort(a,b):
		if b.index > a.index:
			return true
		else:
			return false
	
func break_objects():
	# we need to break lowest index objects first
	#for object in get_children():
	#	if object.to_break:
	#		breaking_children.append(object)
	if special_break:
		yield(get_tree().create_timer(global.seconds_per_move), "timeout")
	
	#unfreeze_all()
	
	breaking_children.sort_custom(self,"mysort")
	if len(breaking_children) > 0:
		print("breaking: " + str(breaking_children))
	for object in breaking_children:
		#if object.to_break:
		object.break_object(false)
	breaking_children = []
	special_break = false
	
func unfreeze_all():
	for vinecell in vinecells:
		vinecell.frozen = false

