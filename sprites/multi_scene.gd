extends Node

var main_scene_protoptype = preload("res://scenes/main.scn")
var timer = 0
var music_play = 0
func _ready():
	set_fixed_process(true)
	set_process_input(true)
#	add_child(main_scene_protoptype.instance())
	get_node("SamplePlayer").play("intro")
	pass

func _fixed_process(delta):
	
	if ( music_play == 0 ):
		if ( timer < 5 ):
			timer += delta
		else:
			music_play = 1
			get_node("SamplePlayer").play("level")
			timer = 0
	
	if (music_play ==1):
		if ( timer < 1 ):
			timer += delta
		else:
			if (Input.is_key_pressed(KEY_SPACE)):
				music_play = 2
				get_node("Sprite1").show()
				timer=0
	if (music_play ==2):
		if ( timer < 1 ):
			timer += delta
		else:
			if (Input.is_key_pressed(KEY_SPACE)):
				music_play =3
				get_node("Sprite1").hide()
				get_node("Sprite").hide()
				start()
	
func restart(restarted_node):
	remove_child(restarted_node)
	get_node("SamplePlayer").stop_all()
	get_node("SamplePlayer").play("level")
	add_child(main_scene_protoptype.instance())

func start():
	add_child(main_scene_protoptype.instance())
	pass