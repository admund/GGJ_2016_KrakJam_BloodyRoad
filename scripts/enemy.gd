extends KinematicBody

### import the input helper class
var enemy_states = preload("enemy_states.gd")
var states       = enemy_states.new()

var type         = 0
var move_vector  = Vector3( 0, 0 ,0 )
var orientation  = 1

var prev_state    = 0
var current_state = 0
var next_state    = 0
var label         = null
var player        = null

func _fixed_process(delta):
	
	get_node("sprite").set_flip_h(orientation)
#	self.move( move_vector )
	
	prev_state = current_state
	current_state = next_state
	
	if ( current_state == states.idle ):
		idle ()
	elif ( current_state == states.attack ):
		attack()
	elif ( current_state == states.chase ):
		chase()
	elif ( current_state == states.run ):
		run()
	elif ( current_state == states.jump ):
		jump()
	elif ( current_state == states.hit ):
		hit()
	elif ( current_state == states.falling ):
		falling()
	elif ( current_state == states.on_ground ):
		on_ground()
	elif ( current_state == states.die ):
		die()
	elif ( current_state == states.delete ):
		delete()
		
		
	
	var tex = get_node("Viewport").get_render_target_texture()
	get_node("Quad").get_material_override().set_texture(FixedMaterial.PARAM_DIFFUSE, tex)
	
func _ready():
	set_fixed_process(true)
	current_state     = states.idle
	label             = get_node("Viewport/Label")
	player            = get_node("../../Player")
	pass
	

func idle ():
	move_vector = (player.get_translation() - self.get_translation())
	var temp = Vector2(move_vector.x, move_vector.z).normalized()
	move_vector.x = temp.x
	move_vector.z = temp.y
	move_vector *= 0.2
	label.set_text("idle")
	pass
	
func attack ():
		
	label.set_text("attack")
	pass
	
func chase ():
	
	label.set_text("chase")
	pass
	
func run ():
	label.set_text("run")
	pass
	
func jump ():
	label.set_text("jump")
	pass

func hit ():
	label.set_text("hit")
	pass
	
func falling ():
	label.set_text("falling")
	pass
	
func on_ground ():
	label.set_text("on_ground")
	pass
	
func die ():
	label.set_text("die")
	pass
	
func delete ():
	label.set_text("delete")
	pass
	