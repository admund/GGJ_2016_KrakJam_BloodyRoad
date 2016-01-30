extends KinematicBody

### import the input helper class
var enemy_states = preload("enemy_states.gd")
var states       = enemy_states.new()

var type         = 0
var move_vector  = Vector3( 0, 0 ,0 )

var prev_state    = 0
var current_state = 0
var next_state    = 0
var label         = null
var player        = null
var jump_target   = Vector3()
var jump_start    = Vector3()
var jump_interpolation = 0
var jump_timer    = 0
var jump_duration = 0

var timer = 0

func _fixed_process(delta):
	
	if (move_vector.x < 0):
		get_node("Sprite").set_flip_h(true)
	else:
		get_node("Sprite").set_flip_h(false)

	self.move( move_vector )
	
	prev_state = current_state
	current_state = next_state
	
	if ( current_state == states.idle ):
		idle ( delta )
	elif ( current_state == states.attack ):
		attack( delta )
	elif ( current_state == states.chase ):
		chase( delta )
	elif ( current_state == states.run ):
		run( delta )
	elif ( current_state == states.jump ):
		jump( delta )
	elif ( current_state == states.hit ):
		hit( delta )
	elif ( current_state == states.falling ):
		falling( delta )
	elif ( current_state == states.on_ground ):
		on_ground( delta )
	elif ( current_state == states.die ):
		die( delta )
	elif ( current_state == states.delete ):
		delete( delta )
		
		
	
	var tex = get_node("Viewport").get_render_target_texture()
	get_node("Quad").get_material_override().set_texture(FixedMaterial.PARAM_DIFFUSE, tex)
	
func _ready():
	set_fixed_process(true)
	current_state     = states.idle
	label             = get_node("Viewport/Label")
	player            = get_node("../../Player")
	pass
func _init():
	randomize()
	timer = rand_range(0,2)
	pass

func idle ( delta ):
	if (current_state != prev_state):
		timer = rand_range(0,2)
		pass
	move_vector = (player.get_translation() - self.get_translation())
	var temp = Vector2(move_vector.x, move_vector.z).normalized()
	move_vector.x = temp.x
	move_vector.z = temp.y
	move_vector *= 0.1
		
	timer += delta
	if (timer >=3):
		next_state = 4
	label.set_text("idle")

	pass
	
func attack ( delta ):
		
	label.set_text("attack")
	pass
	
func chase ( delta ):
	
	label.set_text("chase")
	pass
	
func run ( delta ):
	label.set_text("run")
	pass
	
func jump ( delta ):
	if (current_state != prev_state):
		jump_start         = get_translation()
		jump_target        = player.get_translation()
		jump_interpolation = 0
		jump_timer         = 0
		jump_duration      = (jump_target - jump_start).length()/35
	else:
		jump_timer += delta
		jump_interpolation = jump_timer / jump_duration
		
		var step_target = (1 - jump_interpolation) * jump_start + jump_interpolation * jump_target
		var local_position = get_translation()
		move_vector = step_target - local_position
		jump_interpolation = jump_timer / jump_duration
		get_node("Sprite").set_translation( Vector3(0, sin(jump_interpolation*PI)*15, 0) ) 
		jump_timer += delta
		
		if (jump_timer >=jump_duration):
			next_state = states.idle
			local_position.y = 0
			get_node("Sprite").set_translation( Vector3(0, 0, 0) ) 
			
	
	label.set_text("jump")
	pass

func hit ( delta ):
	label.set_text("hit")
	pass
	
func falling ( delta ):
	label.set_text("falling")
	pass
	
func on_ground ( delta ):
	label.set_text("on_ground")
	pass
	
func die ( delta ):
	label.set_text("die")
	pass
	
func delete ( delta ):
	label.set_text("delete")
	pass
	