
extends Area

var TYPE_PENTAGRAM = 0
var TYPE_HAND = 1

var buff_area_types = preload("buff_area_type.gd").new()
var player_node = null

var timeout = 0
var fade_out_start = false

var blood_splatters = null
var blood_splatters_count = 0

var sprite_pentagram = null
var sprite_hand = null

var enemy = null
var type = TYPE_PENTAGRAM

func _ready():
	set_fixed_process(true)
#	blood_splatters = get_parent().get_parent().get_node("blood").get_children()
#	blood_splatters_count = blood_splatters.get_children_count()
	player_node = get_node("../../Player")
	get_node("pentagram/Particles").set_emitting(true)
	
	sprite_pentagram = get_node("pentagram")
	sprite_hand = get_node("hand")
	
	if(type == TYPE_PENTAGRAM):
		sprite_pentagram.show()
		sprite_hand.hide()
	else:
		sprite_pentagram.hide()
		sprite_hand.show()
		
	if (enemy != null):
		enemy.blow()
		enemy = null
		
	pass

func _on_buff_area_body_exit( body ):
	player_node.set_is_in_buff_area(buff_area_types.NONE)
	pass # replace with function body


func _on_buff_area_body_enter( body ):
	player_node.set_is_in_buff_area(buff_area_types.HEAL)
	pass # replace with function body
	
	
func _fixed_process(delta):
	timeout += delta
	
	if(type == TYPE_PENTAGRAM):
		for i in get_parent().get_parent().get_node("blood").get_children():
			if ((i.get_translation()-get_translation()).length_squared() < 200):
				i.queue_free()
				player_node.add_blood()
				break
			
		if (timeout > 2.5 && !fade_out_start):
			get_node("pentagram/AnimationPlayer").play("fade_out")
			fade_out_start = true
#	else:
#		if (timeout > 4):
#			if(enemy != null):
#				enemy.blow()
		
	if (timeout > 4):
		queue_free()
