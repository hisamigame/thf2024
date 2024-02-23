extends "res://Ending1.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func unlock_difficulty():
	if global.difficulty_unlocked < 2:
		global.difficulty_unlocked = 2
		global.write_to_save()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
