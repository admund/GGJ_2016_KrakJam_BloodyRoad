extends KinematicBody

### import the input helper class
var enemy_states = preload("enemy_states.gd")
var states       = enemy_states.new()

var type         = 0
var hp           = 100
var move_vector  = Vector3( 0, 0 ,0 )
var hit_vector   = Vector3()

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

var orientation = 0

var timer = 0

func _fixed_process(delta):
	
	if ((player.get_translation() - self.get_translation()).x > 0):
		get_node("Area/Sprite").set_flip_h(false)
		orientation = 1
	else:
		get_node("Area/Sprite").set_flip_h(true)
		orientation = -1


	move_vector = Vector3()
	if (hp<=0):
		next_state = states.die
		
	prev_state = current_state
	current_state = next_state
	
	if ( current_state == states.idle ):
		idle ( delta )
	elif ( current_state == states.walk ):
		walk ( delta )
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

	
	self.move( move_vector+hit_vector )

	hit_vector = Vector3()
	
	var tex = get_node("Area/Viewport").get_render_target_texture()
	get_node("Area/Quad").get_material_override().set_texture(FixedMaterial.PARAM_DIFFUSE, tex)
	get_node("Area/Viewport/Sprite1").set_scale(Vector2(hp,1))

	
func _ready():
	set_fixed_process(true)
	current_state     = states.idle
	label             = get_node("Area/Viewport/Label")
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
		
	var new_move_vector = move_vector+ (player.get_translation() - self.get_translation())
	if (abs(new_move_vector.z)>=2):
		var temp = Vector2(0, new_move_vector.z).normalized()
		move_vector.x = 0
		move_vector.z = temp.y * 0.2
	else:
#		move_vector = Vector3()
		timer += delta
		if ( timer >= 5 ):
			next_state = states.jump
	label.set_text("idle")
	pass
func walk ( delta ):
		
	label.set_text("attack")
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
		jump_target        = jump_start
		jump_target.x     += orientation * 40
		jump_interpolation = 0
		jump_timer         = 0
		jump_duration      = (jump_target - jump_start).length()/30
	else:
		jump_timer += delta
		jump_interpolation = jump_timer / jump_duration
		
		var step_target = (1 - jump_interpolation) * jump_start + jump_interpolation * jump_target
		var local_position = get_translation()
		move_vector = step_target - local_position
		jump_interpolation = jump_timer / jump_duration
		get_node("Area").set_translation( Vector3(0, sin(jump_interpolation*PI)*15, 0) ) 
		jump_timer += delta
		
		if (jump_timer >=jump_duration):
			next_state = states.idle
			local_position.y = 0
			get_node("Area").set_translation( Vector3(0, 0, 0) ) 
			
	
	label.set_text("jump")
	pass

func hit ( delta ):
	hp -=10
	if (hp<=0):
		next_state = states.die
	else:
		next_state = prev_state
	label.set_text("hit")
	pass
	
func falling ( delta ):
	label.set_text("falling")
	pass
	
func on_ground ( delta ):
	label.set_text("on_ground")
	pass
	
func die ( delta ):
	if (current_state != prev_state):
		timer = 0
		get_node("Area").set_enable_monitoring(false)

		jump_start         = get_translation()
		jump_target        = jump_start 
		jump_target.x      += orientation * 20
		
	timer += delta
	
	if (timer<=1):
		timer += delta/2
		var step_target = ((1 - timer) * jump_start) + (timer * jump_target)
		var local_position = get_translation()
		var local_positiom_y = get_node("Area").get_translation().y
		move_vector = step_target - local_position
		get_node("Area").set_translation( Vector3(0, (1-timer) * local_positiom_y + sin(timer*PI)*10, 0) ) 
		
	elif (timer>1 and timer<2):
		get_node("Area").set_translation( Vector3(0, 0, 0) ) 
		get_node("Area/Sprite").set_modulate(Color(1,1,1,fmod(timer,0.1)*10))
		move_vector = Vector3()
	elif (timer>=2):
		queue_free()
#		next_state = states.delete
	
	label.set_text("die")
	pass
	
func delete ( delta ):
	queue_free()
	label.set_text("delete")
	pass
	
func _on_Area_body_enter( body ):
	hit_vector = Vector3()
	if (body.get_name()=="bullet"):
		hp-=10
		hit_vector += body.velocity
		body.delete()
	if (body.get_name()=="kameha"):
		hp-=50
		hit_vector += Vector3(1,0,0)

	pass
