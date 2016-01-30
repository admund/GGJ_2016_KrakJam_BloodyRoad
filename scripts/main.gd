extends Spatial

var bulletObject        = preload("res://scenes/bullet.scn")
var enemy_prototype     = preload("res://scenes/enemy.scn")
var blood_splatter_prototype      = preload("res://scenes/blood_splatter.scn")
var blood_particles_prototype      = preload("res://scenes/blood_particles.scn")
var bg_sprite1 = null 
var bg_sprite2 = null
var player = null
var camera_target_position = Vector3(0,0,0)

var enemies_counter = 1

func _fixed_process(delta):
	
	var player_pos = player.get_translation()
	camera_target_position = player_pos - Vector3(player.orientation*20-10,0,0) 
	var bg_pos1 = bg_sprite1.get_translation()
	var bg_pos2 = bg_sprite2.get_translation()
	var camera_pos = get_node("Camera").get_translation() 
	camera_pos.x += ( camera_target_position.x - camera_pos.x )/10
#	camera_pos.x = player_pos.x
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
		
		
	if (get_node("enemies").get_child_count() <= enemies_counter):
		enemies_counter+=1
		spawne_enemy()
	
	var tex = get_node("Camera/GUI").get_render_target_texture()
	get_node("Camera/Quad").get_material_override().set_texture(FixedMaterial.PARAM_DIFFUSE, tex)
	pass
	
func _ready():
	set_fixed_process(true)
	bg_sprite1 = get_node("background/sprite")
	bg_sprite2 = get_node("background/sprite1")
	player = get_node("Player")
	
	spawne_enemy()
	pass

func spawne_enemy():
	var enemies = get_node("enemies")
	for i in range(0,enemies_counter):
		var enemy = enemy_prototype.instance()
		enemy.set_translation(player.get_translation() + Vector3( sign (rand_range(-1, 1))*70, 0, rand_range(-5, -5)))
		enemies.add_child(enemy)
		
func add_blood_splatter(pos):
	var blood = blood_splatter_prototype.instance()
	blood.set_translation(pos)
	blood.set_frame(round(rand_range(2,8)))
	get_node("blood").add_child(blood)
	
func add_blood_particle(pos):
	pos.y+=5
	for i in range(3):
		var blood = blood_particles_prototype.instance()
		blood.set_translation(pos)
		blood.set_linear_velocity(Vector3(rand_range(-15,15),rand_range(5,15),rand_range(-15,15)))
		get_node("blood").add_child(blood)