extends KinematicBody

### import the input helper class
var input_states = preload("input_states.gd")

### create input states classes
var state_up    = input_states.new("up")
var state_down  = input_states.new("down")
var state_left  = input_states.new("left")
var state_right = input_states.new("right")
var state_x     = input_states.new("x")

################################3
var bullet_prototype = preload("res://scenes/bullet.scn")
var buff_area_types = preload("buff_area_type.gd").new()
var bullets_node = null

var btn_up      = null
var btn_down    = null
var btn_left    = null
var btn_right   = null

var btn_x       = null

var is_in_buff_area = buff_area_types.NONE

var player_top_speed_vert = .3;
var player_top_speed_hori = .6;
var move_vector         = Vector3( 0, 0 ,0 )
var orientation         = 0

func _fixed_process(delta):
	
	process_input()
	get_node("sprite").set_flip_h(orientation)
	self.move( move_vector )

func process_input():

	btn_up    = state_up.check()
	btn_down  = state_down.check()
	btn_left  = state_left.check()
	btn_right = state_right.check()
	btn_x =     state_x.check()
	
	move_vector = Vector3( 0, 0, 0 )
	if( btn_up   > 1 ):
		move_vector = Vector3(move_vector.x ,0 , -player_top_speed_vert )
		
	if( btn_down > 1 ):
		move_vector = Vector3(move_vector.x ,0 , player_top_speed_vert )
		
	if( btn_left  > 1 ):
		move_vector = Vector3(-player_top_speed_hori ,0 , move_vector.z )
		orientation = 1
		
	if( btn_right > 1 ):
		move_vector = Vector3( player_top_speed_hori  ,0 , move_vector.z )
		orientation = 0
		
	if ( btn_x == 1 ):
		create_bullet()
		pass
			
	
func _ready():
	set_fixed_process(true)
	set_process_input(true)
	bullets_node = get_node("../bullets")
	pass

func set_is_in_buff_area(buff_area_type):
	is_in_buff_area = buff_area_type
	pass
	
func create_bullet():
#	print("create_bullet")
	var bullet = bullet_prototype.instance()
	bullet.set_translation(self.get_translation() + Vector3(0, 10, 0))
	var bullet_velocity_x = 0
	if orientation == 0:
		bullet_velocity_x = .8
	else:
		bullet_velocity_x = -.8
	
	bullet.velocity = Vector3(bullet_velocity_x,0,0)
	bullets_node.add_child(bullet)
	pass