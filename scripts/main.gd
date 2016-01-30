
extends Spatial

var bulletObject        = preload("res://scenes/bullet.scn")
var bg_sprite1 = null 
var bg_sprite2 = null
var player = null

func _fixed_process(delta):
	
	var player_pos = player.get_translation()
	var bg_pos1 = bg_sprite1.get_translation()
	var bg_pos2 = bg_sprite2.get_translation()
	var camera_pos = get_node("Camera").get_translation()
	camera_pos.x = player_pos.x
	get_node("Camera").set_translation(camera_pos)
	
	if ( player_pos.x > bg_pos1.x ):
		bg_sprite1.set_translation( bg_pos1 + Vector3(200,0,0) )
	if ( player_pos.x < bg_pos1.x - 100 ):
		bg_sprite1.set_translation( bg_pos1 - Vector3(100,0,0) )
#
	if ( player_pos.x > bg_pos2.x + 100 ):
		bg_sprite2.set_translation( bg_pos2 + Vector3(100,0,0) )
	if ( player_pos.x < bg_pos2.x ):
		bg_sprite2.set_translation( bg_pos2 - Vector3(200,0,0) )
		
	
	var tex = get_node("Camera/GUI").get_render_target_texture()
	get_node("Camera/Quad").get_material_override().set_texture(FixedMaterial.PARAM_DIFFUSE, tex)
	pass
	
func _ready():
	set_fixed_process(true)
	bg_sprite1 = get_node("background/sprite")
	bg_sprite2 = get_node("background/sprite1")
	player = get_node("Player")
	pass

