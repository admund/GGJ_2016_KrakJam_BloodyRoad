extends KinematicBody

### import the input helper class
var enemy_states = preload("enemy_states.gd")
var states       = enemy_states.new()

var type         = 0
var hp           = 160
var move_vector  = Vector3( 0, 0 ,0 )
var hit_vector   = Vector3()

var prev_state    = 0
var current_state = 0
var next_state    = 0
var label         = null
var player        = null
var animation     = null
var jump_target   = Vector3()
var jump_start    = Vector3()
var jump_interpolation = 0
var jump_timer    = 0
var jump_duration = 0

var orientation = 0

var timer = 0

var in_sword_range = false
var is_freeze = false

func _fixed_process(delta):

	if ((player.get_translation() - self.get_translation()).x > 0):
		get_node("area_enemy/Sprite").set_flip_h(true)
		orientation = 1
	else:
		get_node("area_enemy/Sprite").set_flip_h(false)
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
	elif ( current_state == states.wait ):
		wait( delta )
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
	elif ( current_state == states.freeze ):
		freeze( delta )
	elif ( current_state == states.blow ):
		blow_up( delta )
	self.move( move_vector+hit_vector )
	hit_vector *=0.9
#	hit_vector = Vector3()
	
	var tex = get_node("area_enemy/Viewport").get_render_target_texture()
	get_node("area_enemy/Quad").get_material_override().set_texture(FixedMaterial.PARAM_DIFFUSE, tex)
	get_node("area_enemy/Viewport/Sprite1").set_scale(Vector2(hp,1))

	
func _ready():
	set_fixed_process(true)
	current_state     = states.idle
	player            = get_node("../../Player")
	animation         = get_node("area_enemy/Sprite/AnimationPlayer")
	pass
	
func _init():
	randomize()
	timer = rand_range(0,2)
	pass

func idle ( delta ):
	if (current_state != prev_state):

		timer = rand_range(0,1)
		pass
		
	var new_move_vector = move_vector+ (player.get_translation() - self.get_translation())
	if (abs(new_move_vector.z)>=2):
		if(animation.get_current_animation()!= "walk"):
			animation.play("walk")
			
		var temp = Vector2(0, new_move_vector.z ).normalized()
		move_vector.x = 0
		move_vector.z = temp.y * 0.1
		get_node("Particles").set_emitting(true)
		get_node("Particles1").set_emitting(true)
		get_node("Particles2").set_emitting(true)

	else:
		if(animation.get_current_animation()!= "idle"):
			animation.play("idle")
		timer += delta
		var local_length = (player.get_translation() - self.get_translation()).length()
		if ( timer >= 3 or local_length<10):
#			var local_length = (player.get_translation() - self.get_translation()).length()
			if (local_length<10):
				next_state = states.attack
			elif(local_length>=10 and local_length<30):
				next_state = states.walk
			else:
				next_state = states.run
	pass
	
func freeze ( delta ):
	is_freeze = true
	pass
	
func walk ( delta ):
	if (current_state != prev_state):
		jump_start         = get_translation()
		jump_target        = player.get_translation()
		jump_target        = Vector3(jump_target.x -sign(jump_target.x)*4, 0 ,jump_target.z)
		jump_interpolation = 0
		jump_timer         = 0
		jump_duration      = 1  
	else:
		if(animation.get_current_animation()!= "walk"):
			animation.play("walk")
			
		jump_timer += delta
		jump_interpolation = jump_timer / jump_duration
		
		var step_target = (1 - jump_interpolation) * jump_start + jump_interpolation * jump_target
		var local_position = get_translation()
		
		move_vector = step_target - local_position
		if (jump_timer >=jump_duration):
			next_state = states.idle
	pass
	
func attack ( delta ):
	if (current_state != prev_state):
		timer = 0
		
	if(animation.get_current_animation()!= "attack"):
		animation.play("attack")
	
	timer += delta
	if (timer >=1):
		next_state = states.idle
		
	pass
func wait( delta ):
	if (current_state != prev_state):
		timer = 0
		
	if(animation.get_current_animation()!= "attack"):
		animation.play("attack")
	
	timer += delta
	if (timer >=3):
		next_state = states.idle
		
	pass	
func run ( delta ):
	if (current_state != prev_state):
		jump_start         = get_translation()
		jump_target        = jump_start + Vector3( orientation * 80,0,0)
		jump_interpolation = 0
		jump_timer         = 0
		jump_duration      = 1

	else:
		if(animation.get_current_animation()!= "run"):
			animation.play("run")
		get_node("Particles").set_emitting(true)
		get_node("Particles1").set_emitting(true)
		get_node("Particles2").set_emitting(true)
		jump_timer += delta 
		jump_interpolation = jump_timer  / jump_duration
		
		
		var step_target = (1 - jump_interpolation) * jump_start + jump_interpolation * jump_target
		var local_position = get_translation()
		
		move_vector = step_target - local_position
		if (jump_timer >=jump_duration):
			next_state = states.wait
	pass
	

func sword_hit(sword_trans):
	var result = sword_trans - get_translation()
#	if (in_sword_range):
	if (result.length() < 10):
		hp-=16 + (player.blood_rage_on * 4)*16
		hit ( player.get_translation())

func hit ( hit_location ):
	get_parent().get_parent().get_node("SamplePlayer").play("hit"+str(round(rand_range(2,3))))
	get_parent().get_parent().add_blood_particle(get_translation())
	var local_hit_vector = (hit_location-get_translation())
	local_hit_vector.y = 0
	local_hit_vector.z = 0
	hit_vector -= local_hit_vector.normalized()*0.5
	pass
	
	
func die ( delta ):
	if (current_state != prev_state):
		timer = 0
		if(animation.get_current_animation()!= "dead"):
			animation.play("dead")
		get_node("area_enemy").set_enable_monitoring(false)

		jump_start         = get_translation()
		jump_target        = jump_start 
		jump_target.x      -= orientation * 5
		
	timer += delta
	
	if (timer<=1):
		timer += delta/2
		var step_target = ((1 - timer) * jump_start) + (timer * jump_target)
		var local_position = get_translation()
		var local_positiom_y = get_node("area_enemy").get_translation().y
		move_vector = step_target - local_position
		get_node("area_enemy").set_translation( Vector3(0, (1-timer) * local_positiom_y + sin(timer*PI), 0) ) 
		
	elif (timer>1 and timer<2):
		get_node("area_enemy").set_translation( Vector3(0, 0, 0) ) 
		get_node("area_enemy/Sprite").set_modulate(Color(1,1,1,fmod(timer,0.1)*10))
		move_vector = Vector3()
	elif (timer>=2):
		delete(delta)
	
	pass
	
func blow():
	next_state = states.blow
	pass
	
func blow_up(delta):
	if (current_state != prev_state):
		timer = 0
	get_node("area_enemy/Sprite").translate(Vector3(0,0.01,0.01))
		
	timer+=delta
	if (timer>=1):
		get_parent().get_parent().add_bloow_particles(get_translation())
		player.current_hp+=50
		is_freeze = false
		delete(1)
	pass
	
func delete ( delta ):
	if(!is_freeze):
		get_parent().get_parent().sum_xp += get_parent().get_parent().tank
		queue_free()
	pass
	
func _on_Area_body_enter( body ):
#	hit_vector = Vector3()
#	hit_vector = Vector3()
	if (body.has_node("bullet_type")):
		hp-=32
#		hit_vector += body.velocity
		hit(body.get_translation())
		body.delete()
		return
		
	if (body.has_node("gun_bullet_type")):
		hp-=10
#		hit_vector += body.velocity
		hit(body.get_translation())
		body.delete()
		return

	if (body.get_name()=="kameha"):
		hp-=120
		hit(body.get_translation())
		return

	pass
