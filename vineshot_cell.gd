extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var sprite = $AnimatedSprite

enum DIRECTION {LEFT, UP, RIGHT, DOWN, NOT_YET}

export(DIRECTION) var state = DIRECTION.LEFT

var animation_name = ""
var final_animation_name = ""

var index = -1

# Called when the node enters the scene tree for the first time.
func _ready():
	set_state(state)
	

func set_state(new_state):
	if new_state == DIRECTION.LEFT:
		animation_name = "s_left"
		final_animation_name = "right"
	elif new_state == DIRECTION.RIGHT:
		animation_name = "s_right"
		final_animation_name = "right"
	elif new_state == DIRECTION.UP:
		animation_name = "s_up"
		final_animation_name = "up"
	elif new_state == DIRECTION.DOWN:
		animation_name = "s_down"
		final_animation_name = "up"
	
	sprite.play(animation_name)

func _on_AnimatedSprite_animation_finished():
	if sprite.animation[0] == "s":
		sprite.play(final_animation_name)
	
