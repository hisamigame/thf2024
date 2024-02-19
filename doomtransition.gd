extends ColorRect

var melting := false
var timer := 0.0

export var x_resolution = 100.0
export var max_offset = 2.0
export var melt_speed = 0.02

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	


func _process(_delta):
	if melting:
		timer += melt_speed
		self.material.set_shader_param("timer", timer)
		

# Call this before transitioning, creates a copy of the screen texture so changes
# can be made underneath before melting to show the new screen.
func generate_offsets():
	var rng = RandomNumberGenerator.new()
	var offsets = []
	for i in x_resolution:
		offsets.append(rng.randf_range(1.0, max_offset))
	#self.material.set_shader_parameter("y_offsets", offsets)
	
	var img = get_viewport().get_texture().get_data()
	img.flip_y()
	var tex = ImageTexture.new()
	tex.create_from_image(img)
	self.material.set_shader_param("melt_tex", tex)
	show()
	update()

# Call this after generate_offsets
func transition():
	self.material.set_shader_param("melting", true)
	melting = true
