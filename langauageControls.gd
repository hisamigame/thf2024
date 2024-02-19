extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
func cycle_language():
	global.play_language()
	if TranslationServer.get_locale() == "en":
		TranslationServer.set_locale("ja")
		$language.frame=1
	else:
		TranslationServer.set_locale("en")
		$language.frame=0
	global.redo_scene()

# Called when the node enters the scene tree for the first time.

func _ready():
	if TranslationServer.get_locale() == "en":
		$language.frame=0
	else:
		$language.frame=1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("language"):
		cycle_language()
