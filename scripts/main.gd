
extends Spatial

var bulletObject        = preload("res://scenes/bullet.scn")

func _fixed_process(delta):
	
	var tex = get_node("GUI").get_render_target_texture()
	get_node("Quad").get_material_override().set_texture(FixedMaterial.PARAM_DIFFUSE, tex)
	pass
	
func generateBullet( bulletPosition, bulletValocity ):
#	var bullets = get_node("bullets")
#	
#	var new_bullet = bulletObject.instance()
#	new_bullet.set_pos( bulletPosition )
#	new_bullet.velocity = (bulletValocity + Vector2(rand_range(-0.03,0.03),rand_range(-0.03,0.03))) *10
#	
#	bullets.add_child( new_bullet )

	pass
	
func _ready():
	set_fixed_process(true)
	
	pass

