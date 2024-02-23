extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var dangerous = false
var player_y = 3000
var fade_level = 0
var y = 0
var ymin = -4.0
var ymax = -23.0

func _ready():
	pass # Replace with function body.
	global.stage=20

func _process(_delta):
	player_y = get_parent().get_node("YSort/grid/hisami").cell.y
	y = clamp(player_y,ymax, ymin)
	fade_level = (y - ymin)/(ymax-ymin)
	$TextureRect.color.a = fade_level

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func take_damage():
	pass

func _on_detection_area_entered(_area):
	pass
	#$AnimationPlayer.play("fade")


func _on_detection_area_exited(_area):
	pass
	#$AnimationPlayer.play("unfade")
