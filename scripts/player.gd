extends KinematicBody

var STATE_IDLE = 0
var STATE_RUNNING = 1
var STATE_JUMP = 2
var STATE_CASTING = 3 

### import the input helper class
var input_states = preload("input_states.gd")

### create input states classes
var state_up    = input_states.new("up")
var state_down  = input_states.new("down")
var state_left  = input_states.new("left")
var state_right = input_states.new("right")
var state_jump = input_states.new("jump")
var state_x     = input_states.new("x")
var state_1     = input_states.new("1")
var state_2     = input_states.new("2")
var state_3     = input_states.new("3")

################################3
var bullet_prototype = preload("res://scenes/bullet.scn")
var bullets_node = null

var buff_area_prototype = preload("res://scenes/arena.scn")
var buff_area_types = preload("buff_area_type.gd").new()
var buff_areas_node = null

var kameha_prototype = preload("res://scenes/kameha.scn")
var shell_prototype = preload("res://scenes/shell.scn")
var shell_node = null
#var buff_areas_node = null

var btn_up      = null
var btn_down    = null
var btn_left    = null
var btn_right   = null
var btn_jump   = null
var btn_x       = null
var btn_1       = null
var btn_2       = null
var btn_3       = null

var is_in_buff_area = buff_area_types.NONE

var player_jump_hight = 1.2
var player_top_speed_vert = .3;
var player_top_speed_hori = .6;
var move_vector         = Vector3( 0, 0 ,0 )
var orientation         = 0

# sprites
var current_state = STATE_IDLE

var sprite_idle = null
var sprite_running = null
var sprite_jump = null
var sprite_casting = null

# timeouts
var jump_timeout = -1
var buff_area_timeout = -1
var bullet_timeout = -1
var kameha_timeout = -1
var throw_cast_timeout = -1

func _fixed_process(delta):
	process_input()
	decrese_timeouts(delta)
	sprite_idle.set_flip_h(orientation)
	sprite_running.set_flip_h(orientation)
	sprite_jump.set_flip_h(orientation)
	sprite_casting.set_flip_h(orientation)

	# powrot do "trans.y = 0" po skakaniu
	if(current_state != STATE_JUMP && get_translation().y != 0 ):
		var trans = get_translation()
		set_translation(Vector3(trans.x, 0, trans.z))
	elif(throw_cast_timeout < 0):
		self.move( move_vector )

func process_input():
	btn_up    = state_up.check()
	btn_down  = state_down.check()
	btn_left  = state_left.check()
	btn_right = state_right.check()
	btn_jump  = state_jump.check()
	btn_x =     state_x.check()
	btn_1 =     state_1.check()
	btn_2 =     state_2.check()
	btn_3 =     state_3.check()
	
	var move = false
	move_vector = Vector3( 0, 0, 0 )
	if( btn_up   > 1 ):
		move_vector = Vector3(move_vector.x ,0 , -player_top_speed_vert )
		move = true
		
	if( btn_down > 1 ):
		move_vector = Vector3(move_vector.x ,0 , player_top_speed_vert )
		move = true
		
	if( btn_left  > 1 ):
		move_vector = Vector3(-player_top_speed_hori ,0 , move_vector.z )
		orientation = 1
		move = true
		
	if( btn_right > 1 ):
		move_vector = Vector3( player_top_speed_hori,0 , move_vector.z )
		orientation = 0
		move = true
		
	if(btn_jump == 1 && (current_state == STATE_RUNNING || current_state == STATE_IDLE)):
		change_state(STATE_JUMP)
		jump_timeout = 1
		
		
	if(current_state == STATE_JUMP):
		move_vector = Vector3(move_vector.x, cos((1 - jump_timeout) * PI) * player_jump_hight, move_vector.z)
		
	if (current_state == STATE_RUNNING || current_state == STATE_IDLE):
		if (move):
			change_state(STATE_RUNNING)
		else:
			change_state(STATE_IDLE)
		
	if (btn_1 == 1 && buff_area_timeout < 0):
		create_buff_area(1)
		buff_area_timeout = 4
		throw_cast_timeout = 2.5
		change_state(STATE_CASTING)
	
	if (btn_2 == 1 && bullet_timeout < 0):
#		create_buff_area(2)
		create_bullet()
		bullet_timeout = .5
	
	if (btn_3 == 1 && kameha_timeout < 0):
#		create_buff_area(3)
		create_kameha()
		kameha_timeout = 3 #10
		throw_cast_timeout = 1.5
		change_state(STATE_CASTING)
	
func decrese_timeouts(delta):
	if(buff_area_timeout > 0):
		buff_area_timeout -= delta
		
	if(bullet_timeout > 0):
		bullet_timeout -= delta
	
	if(throw_cast_timeout > 0):
		throw_cast_timeout -= delta
		if(throw_cast_timeout < 0):
			change_state(STATE_IDLE)
			
	if(jump_timeout > 0):
		jump_timeout -= delta
		if(jump_timeout < 0):
			change_state(STATE_IDLE)
				
	if(kameha_timeout > 0 && is_in_buff_area != buff_area_types.NONE):
		print(kameha_timeout)
		kameha_timeout -= delta
	
func _ready():
	set_fixed_process(true)
	set_process_input(true)
	
	shell_node      = get_node("../shells")
	bullets_node    = get_node("../bullets")
	buff_areas_node = get_node("../buff_areas")
	
	sprite_idle     = get_node("sprite_idle")
	sprite_jump     = get_node("sprite_jump")
	sprite_running  = get_node("sprite_running")
	sprite_casting  = get_node("sprite_casting")
	pass

func set_is_in_buff_area(buff_area_type):
	is_in_buff_area = buff_area_type
	pass
	
func create_bullet():
	var bullet = bullet_prototype.instance()
	var shell = shell_prototype.instance()
	
	shell.set_angular_velocity(Vector3(rand_range(-0.1,0.1),rand_range(-0.1,0.1),rand_range(-0.1,0.1)))
	shell.set_linear_velocity(Vector3(rand_range(-2,2),rand_range(-4,0.5),rand_range(-0.5,0.5)))
	shell.set_translation(self.get_translation() + Vector3(-5*orientation, 10+rand_range(-1,1), 0))
	shell_node.add_child(shell)
	bullet.set_translation(self.get_translation() + Vector3(0, 10, 0))
	var bullet_velocity_x = 0
	if orientation == 0:
		bullet_velocity_x = .8
	else:
		bullet_velocity_x = -.8
	
	bullet.velocity = Vector3(bullet_velocity_x,0,0)
	bullet.get_node("Sprite3D").set_flip_h(orientation)
	bullets_node.add_child(bullet)
	pass
	
func create_buff_area(buff_area_type):
	var buff_area = buff_area_prototype.instance()
	buff_area.set_translation(self.get_translation())
	buff_areas_node.add_child(buff_area)
	pass
	
func create_kameha():
	var kameha = kameha_prototype.instance()
	kameha.set_translation(self.get_translation() + Vector3(0, 10, 0))
	var velocity_x = 0
	if orientation == 0:
		velocity_x = .8
	else:
		velocity_x = -.8
		
	kameha.velocity = Vector3(velocity_x, 0, 0)
	kameha.set_orientation( orientation )
#	kameha.get_node("anim_sprite").set_flip_h(orientation)
#	if orientation == 1:
#		scale.x = scale.x * -1
	bullets_node.add_child(kameha)
	pass
	
func change_state(new_state):
	current_state = new_state
	if(new_state == STATE_IDLE):
		sprite_idle.show()
		sprite_running.hide()
		sprite_jump.hide()
		sprite_casting.hide()
		
	elif(new_state == STATE_RUNNING):
		sprite_idle.hide()
		sprite_running.show()
		sprite_jump.hide()
		sprite_casting.hide()
		
	elif(new_state == STATE_JUMP):
		sprite_idle.hide()
		sprite_running.hide()
		sprite_jump.show()
		sprite_casting.hide()
		
	elif(new_state == STATE_CASTING):
		sprite_idle.hide()
		sprite_running.hide()
		sprite_jump.hide()
		sprite_casting.show()
		
		