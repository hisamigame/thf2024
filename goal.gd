extends "res://gridObject.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

enum FLAVORS {MOKOU, KAGUYA, REISEN, ZANMU}

export(FLAVORS) var flavor = FLAVORS.MOKOU

onready var sprite = $pivot/AnimatedSprite

var grabable = true
var pushable = true
var end_stage = true
var can_fall = true
var can_press = true



# Called when the node enters the scene tree for the first time.
func _ready():
	type = CELL_TYPES.OBSTACLE
	offset = Vector2(0,-8)
	y_offset = 8

func current_sprite():
	# for animated sprites, would return the current frame
	# return sprite.get_frame_texture(sprite.animation, sprite.frame)
	var texture=sprite.get_sprite_frames().get_frame(sprite.animation,sprite.get_frame())
	return texture

func set_night():
	modulate = Color('7e75cf')
	
func set_day():
	modulate = Color('ffffff')

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


func update_sprite():
	match flavor:
		FLAVORS.MOKOU:
			sprite.play("mokou")
		FLAVORS.KAGUYA:
			sprite.play("kaguya")
		FLAVORS.ZANMU:
			sprite.play("zanmu")

func fall():
	global.show_reset()
	if can_fall:
		$Timer.start(global.seconds_per_move * 1.5)
		can_fall = false
	
func actually_fall():
	sprite.z_index = -2
	global.play_fall()
	sprite.play("fall")
	

func _on_Timer_timeout():
	actually_fall()


func _on_AnimatedSprite_animation_finished():
	if sprite.animation == 'fall':
		queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

