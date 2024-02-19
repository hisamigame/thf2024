extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var hp = 1

var dangerous = true
var danger_cooldown = 0.05
var on_CD = false
var wait_time = 0.0

enum DIRECTION {LEFT, UP, RIGHT, DOWN, NOT_YET}
const direction_vecs = [Vector2.LEFT,Vector2.UP,Vector2.RIGHT,Vector2.DOWN]

export var speed = 0.0
export(DIRECTION) var direction = DIRECTION.DOWN

# Called when the node enters the scene tree for the first time.
func _physics_process(delta):
	if on_CD:
		wait_time = wait_time + delta
		if wait_time > danger_cooldown:
			on_CD = false
			dangerous = true
	if speed > 0:
		position = position + speed * direction_vecs[direction] * delta
	

func _ready():
	global.play_expel()

func take_damage():
	dangerous = false
	on_CD = true
	wait_time = 0.0
	hp = hp -1
	if hp == 0:
		break_self()
		
func break_self():
	dangerous = false
	on_CD = false
	set_deferred("monitorable", false)
	monitoring = false
	#queue_free()
	call_deferred("queue_free")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
