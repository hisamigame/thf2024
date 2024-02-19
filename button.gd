extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var pressed = false
export var must_hold = true
export var gategroup = 0
var can_press = true
var just_pressed = false

var dangerous = false

export var alt_color = 0

var id = 0

var which_frame = 0

var unpress_time = 0.0
var max_unpress_time = global.seconds_per_move/2

onready var sprite = $AnimatedSprite

# Called when the node enters the scene tree for the first time.
func _ready():
	which_frame =  alt_color
	sprite.frame = which_frame
	
func set_night():
	modulate = Color('7e75cf')
	
func set_day():
	modulate = Color('ffffff')

func _process(delta):
	if must_hold:
		can_press = true
	if just_pressed:
		unpress_time = unpress_time + delta
		if unpress_time > max_unpress_time:
			just_pressed = false
			unpress_time = 0.0

func press():
	#print("press " + str(pressed))
	#if !pressed:
	pressed = true
	just_pressed = true
	sprite.animation = "pressed"
	sprite.frame = which_frame
	global.call_gate(gategroup, id)
	can_press = false
	print("id: " + str(id) + " pressed")
	
func unpress():
	pressed = false
	$AnimatedSprite.animation = "default"
	sprite.frame = which_frame
	global.uncall_gate(gategroup, id)
	print("unpressed: " + str(id))

func _on_button_area_entered(_area):
	#if can_press:
	press()
		


func _on_button_area_exited(_area):
	if must_hold:
		if !just_pressed:
			can_press = true
			unpress()

func take_damage():
	# for interface
	pass
