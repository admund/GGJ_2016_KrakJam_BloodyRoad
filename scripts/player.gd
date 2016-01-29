extends KinematicBody

### import the input helper class
var input_states = preload("input_states.gd")

### create input states classes
var state_up    = input_states.new("up")
var state_down  = input_states.new("down")
var state_left  = input_states.new("left")
var state_right = input_states.new("right")
var state_x     = input_states.new("x")

var btn_up      = null
var btn_down    = null
var btn_left    = null
var btn_right   = null

var btn_x       = null

var move_vector         = Vector3( 0, 0 ,0 )

var orientation         = 0


func _fixed_process(delta):
	
	process_input()
	get_node("sprite").set_flip_h(orientation)
	self.move( move_vector )
	
	print(get_collider())

func process_input():

	btn_up    = state_up.check()
	btn_down  = state_down.check()
	btn_left  = state_left.check()
	btn_right = state_right.check()
	btn_x =     state_x.check()
	
	move_vector = Vector3( 0, 0, 0 )
	if( btn_up   > 1 ):
		move_vector = Vector3(move_vector.x ,0 , -1 )
		
	if( btn_down > 1 ):
		move_vector = Vector3(move_vector.x ,0 , 1 )
		
	if( btn_left  > 1 ):
		move_vector = Vector3(-2 ,0 , move_vector.z )
		orientation = 1
		
	if( btn_right > 1 ):
		move_vector = Vector3( 2  ,0 , move_vector.z )
		orientation = 0
		
	if ( btn_x > 1 ):
		pass
			
	
func _ready():
	set_fixed_process(true)
	set_process_input(true)
	pass