
extends Spatial

var velocity = null
var timeout = 0

var anim_sprite = null
var middle_sprite = null
var end_sprite = null
var orientation = 0
var colider =null

func _ready():
	set_fixed_process(true)
	anim_sprite   = get_node("anim_sprite")
	middle_sprite = get_node("middle")
	end_sprite    = get_node("kameha/end")
	colider       = get_node("kameha")
	anim_sprite.set_flip_h(orientation)
	end_sprite.set_flip_h(orientation)
	if(orientation):
		self.set_translation(get_translation()+Vector3(-4,0,0))
		colider.set_translation(Vector3(-1.27,0,0))
		middle_sprite.set_translation(Vector3(-0.64,0,0))
	else:
		self.set_translation(get_translation()+Vector3(4,0,0))
		colider.set_translation(Vector3(1.27,0,0))
		middle_sprite.set_translation(Vector3(0.64,0,0))
		
func _fixed_process(delta):
	timeout += delta
	
	if ( timeout > 1 and timeout < 3 ):
		
		if (orientation):
			middle_sprite.set_scale(Vector3((1-timeout)*3,1,1))
			colider.move(Vector3( -1.5, 0, 0 ))
		else:
			middle_sprite.set_scale(Vector3((timeout-1)*3,1,1))
			colider.move(Vector3( 1.5, 0, 0 ))
	if (timeout>=1):
		var local_color = Color(1,1,1, 2-timeout)
		anim_sprite.set_modulate( local_color )
		middle_sprite.set_modulate( local_color )
		end_sprite.set_modulate( local_color )
		timeout += delta*2
	if (timeout>=2):
		queue_free()

func set_orientation(new_orientation):
	orientation = new_orientation

func fadeout():
	timeout = 3
	