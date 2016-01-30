
extends KinematicBody

var velocity = null
var timeout = 0
var fade_out_start = false

var anim_sprite = null
var middle_sprite = null
var end_sprite = null

func _ready():
	set_fixed_process(true)
	anim_sprite = get_node("anim_sprite")
	middle_sprite = get_node("kameha_node_2/middle")
	end_sprite = get_node("kameha_node_2/end")

func _fixed_process(delta):
	timeout += delta
	
	if (timeout>2 || !fade_out_start):
		get_node("kameha_node_2").show()
		anim_sprite.hide()
		fade_out_start = true
		
	if (fade_out_start):
		end_sprite.set_translation( end_sprite.get_translation() + velocity/10 )
