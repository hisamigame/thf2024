extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var time = 0.0
var firing = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	#fire()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if firing:
		time = time + delta
		$laser.material.set_shader_param('time',time)

func stand():
	$AnimatedSprite.playing=false


func fire():
	$laser.visible = true
	firing = true
	$Timer.start(1.0)
	

func _on_Timer_timeout():
	$laser.visible=false
	firing = false
