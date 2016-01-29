
extends Area

var buff_area_types = preload("buff_area_type.gd").new()
var player_node = null

func _ready():
	player_node = get_node("../Player")
	pass

func _on_buff_area_body_exit( body ):
	print("no hit")
	player_node.set_is_in_buff_area(buff_area_types.NONE)
	pass # replace with function body


func _on_buff_area_body_enter( body ):
	print("hit")
	player_node.set_is_in_buff_area(buff_area_types.HEAL)
	pass # replace with function body
