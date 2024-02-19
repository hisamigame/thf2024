extends "res://gridObject.gd"

onready var grid = get_tree().get_root().get_node("world/YSort/grid")
onready var gate_grid = get_tree().get_root().get_node("world/YSort/gategrid")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const grabable = false
const pushable = false
const autograb = false
const dangerous = false

var to_break = false
var to_recount = true

var hurtable = false

export var gategroup = 0

export var threshold = 1

export var total = 0

func _enter_tree():
	var _tmp = global.connect("signal_gate", self, "signal_got")
	_tmp = global.connect("unsignal_gate", self, "signal_ungot")
	_tmp = global.connect("supdate_gate", self, "update_gate")

onready var sprite = $pivot/AnimatedSprite
onready var breakbox = $pivot/breakbox

var jammed = false
var time = 0.0
var wait_time = global.seconds_per_move

export var never_reverts = false
export (int) var state = 0

var to_update = false
var cant_close = false

var button_array = []

var close_frame = 2

func set_night():
	print('set gate night')
	sprite.animation = "closenight"

func set_day():
	sprite.animation = "close"

# Called when the node enters the scene tree for the first time.
func set_button_array(n):
	button_array = []
	button_array.resize(n)
	button_array.fill(false)

func _ready():
	type = -1
	sprite.animation = "close"
	sprite.playing = false
	sprite.frame = state
	if state >= close_frame:
		close()
	else:
		open()
	
func set_state(s):
	state = s
	sprite.frame = s
	
func open():
	if state > 0:
		set_state(state-1)
	
	if state == 0:
		type = -1
		z_index = -2
		set_deferred("monitorable", false)
		breakbox.monitoring = false
		gate_grid.set_cellv(cell,-1)
	#breakbox.monitorable = false
	
func _process(delta):
	recount()
	if to_recount:
		recount()
		to_recount = false
	if to_update:
		time = time + delta
		if time > wait_time:
			time = 0.0
			if total < threshold:
				if cell_free():
					close()
				else:
					open()
			else:
				if never_reverts:
					cant_close = true
				open()
		to_update = false

func update_gate(_delta):
	to_update = true
	
func close():
	if state < 3 and cell_free() and !cant_close:
		set_state(state+1)

	if state >= close_frame:
		z_index = 0
		type = CELL_TYPES.GATE
		gate_grid.set_cellv(cell,CELL_TYPES.GATE)
		set_deferred("monitorable", true)
		breakbox.monitoring = true

func cell_free():
	var id = grid.get_cellv(cell)
	var maybe = false
	if id == -1 or id == CELL_TYPES.GATE:
		maybe = true
	if maybe:
		var obj = grid.get_cell_of_type(cell, CELL_TYPES.PLAYER)
		if obj != null:
			return false
		obj = grid.get_cell_of_type(cell, CELL_TYPES.OBSTACLE)
		if obj != null:
			return false
		obj = grid.get_cell_of_type(cell, CELL_TYPES.VINE)
		if obj != null:
			return false
		obj = grid.get_cell_of_type(cell, CELL_TYPES.VINESHOOT)
		if obj != null:
			return false
		return true
		
	else:
		return false
	
func signal_got(signal_gategroup, _button_id):
	if gategroup == signal_gategroup:
		#button_array[button_id] = true
		to_recount = true
	
func move():
	pass	
	
func signal_ungot(signal_gategroup, _button_id):
	if gategroup == signal_gategroup:
		#button_array[button_id] = false
		to_recount = true
	
func recount():
	total = 0
	for e in get_parent().get_parent().get_parent().button_array:
		if e.pressed and e.gategroup == gategroup:
			total = total + 1
	#print(total)
	#print(button_array)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_breakbox_area_entered(area):
		if state >= close_frame:
			area.take_damage()
