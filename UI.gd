extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


enum FLAVORS {MOKOU, KAGUYA, REISEN, ZANMU}

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
	match flavor:
		FLAVORS.MOKOU:
			texture = load("res://Level_transition_M.png")
		FLAVORS.KAGUYA:
			texture = load("res://Level_transition_K.png")
		FLAVORS.REISEN:
			texture = load("res://redeyes_placeholder.png")
		FLAVORS.ZANMU:
			texture = load("res://redeyes_placeholder.png")
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
		if global.stage < 100:
			# Normal clear
			$AnimationPlayer.play("endingTransition")
		elif global.stage < 200:
			# Hard clear
			$AnimationPlayer.play("endingTransitionH")
		else:
			# Lunatic clear
			$AnimationPlayer.play("endingTransitionL")
	

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"stageTransitionIn":
			#global.softpause()
			global.actually_change_level2()
		"endingTransition", "endingTransitionH", "endingTransitionL":
			#global.softpause()
			global.end_game()
		"stageTransitionOut":
			global.can_unsoftpause = true

func show_spell():
	$AnimationPlayer.play("spell")
	
func unshow_spell():
	$AnimationPlayer.play("unspell")
