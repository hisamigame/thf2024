extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


enum FLAVORS {MOKOU, KAGUYA}

onready var level_clear_image = $CanvasLayer/TextureRect
onready var label = $CanvasLayer/CenterContainer/Label
onready var game_clear_image = $CanvasLayer/ending

func _enter_tree():
	var _tmp = global.connect("pause_signal", self, "handle_pause")
	_tmp = global.connect("next_stage2", self, "to_next_stage")
	_tmp = global.connect("view_message", self, "view_message")

func update_message():
	label.text = global.message

func view_message():
	label.visible = true
	label.text = global.message

func update_texture(flavor):
	var texture
	if flavor == FLAVORS.MOKOU:
		texture = load("res://Level_transition_M.png")
	else:
		texture = load("res://Level_transition_K.png")
	level_clear_image.texture = texture

func _ready():
	level_clear_image.visible = true
	game_clear_image.visible = true
	game_clear_image.material.set_shader_param("cutoff", 1.0)
	
	if global.new_level:
		level_clear_image.material.set_shader_param("cutoff", 0.0)
		$AnimationPlayer.play("stageTransitionOut")
		global.new_level = false
		#global.softpause()
	else:
		level_clear_image.material.set_shader_param("cutoff", 1.0)
		global.set_unsoftpause_timer()

func handle_pause(is_paused):
	if is_paused:
		label.visible = true
		label.text = global.message
	else:
		label.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func to_next_stage():
	update_texture(global.flavor)
	global.play_win()
	if global.next_level_exists():
		$AnimationPlayer.play("stageTransitionIn")
	else:
		$AnimationPlayer.play("endingTransition")
	

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "stageTransitionIn":
		#global.softpause()
		
		global.actually_change_level2()
	elif anim_name == "endingTransition":
		#global.softpause()
		global.end_game()
	elif anim_name == "stageTransitionOut":
		global.can_unsoftpause = true

func show_spell():
	$AnimationPlayer.play("spell")
	
func unshow_spell():
	$AnimationPlayer.play("unspell")
