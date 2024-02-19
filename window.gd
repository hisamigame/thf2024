extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var scrollspeedx = 4.0
export var scrollspeedy = 4.0#2.5
var xoffset = 0
var yoffset = 0
# Called when the node enters the scene tree for the first time.
var night = false

func set_night():
	#set_process(true)
	$frame.frame = 1

func set_day():
	#set_process(false)
	$starBG.visible = false
	$frame.frame = 0

func _ready():
	pass # Replace with function body.



#func _process(delta):
#	xoffset = fmod(xoffset + scrollspeedx*delta, 256.0)
#	yoffset = fmod(yoffset + scrollspeedy*delta, 256.0)
#	$starBG.region_rect  = Rect2(xoffset, yoffset, 64, 96)
