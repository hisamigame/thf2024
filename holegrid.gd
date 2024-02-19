extends TileMap


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_night():
	modulate = Color('7e75cf')
	
func set_day():
	modulate = Color('ffffff')

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
