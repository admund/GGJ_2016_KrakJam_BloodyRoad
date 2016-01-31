extends Node

var main_scene_protoptype = preload("res://scenes/main.scn")

func _ready():
	add_child(main_scene_protoptype.instance())
	get_node("SamplePlayer").play("main_theme")
	pass
	
func restart(restarted_node):
	remove_child(restarted_node)
	add_child(main_scene_protoptype.instance())
	