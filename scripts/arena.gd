
extends Area

var buff_area_types = preload("buff_area_type.gd").new()
var player_node = null

var timeout = 0
var fade_out_start = false

var blood_splatters = null
var blood_splatters_count = 0

func _ready():
	set_fixed_process(true)
#	blood_splatters = get_parent().get_parent().get_node("blood").get_children()
#	blood_splatters_count = blood_splatters.get_children_count()
	player_node = get_node("../../Player")
	get_node("Sprite3D/Particles").set_emitting(true)
	pass

func _on_buff_area_body_exit( body ):
	player_node.set_is_in_buff_area(buff_area_types.NONE)
	pass # replace with function body


func _on_buff_area_body_enter( body ):
	player_node.set_is_in_buff_area(buff_area_types.HEAL)
	pass # replace with function body
	
	
func _fixed_process(delta):
	timeout += delta
	for i in get_parent().get_parent().get_node("blood").get_children():
		if ((i.get_translation()-get_translation()).length_squared() < 200):
			i.queue_free()
			player_node.add_blood()
			break
		
	if (timeout > 2.5 && !fade_out_start):
		get_node("Sprite3D/AnimationPlayer").play("fade_out")
		fade_out_start = true
		
	if (timeout > 4):
		queue_free()
