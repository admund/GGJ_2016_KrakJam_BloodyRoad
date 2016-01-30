
extends RigidBody


func _ready():
	set_fixed_process(true)
	
	pass
	
func _fixed_process(delta):
	var local_pos = get_translation()
	if (local_pos.y<=0):
		local_pos.y = 0
		if (local_pos.z>1):
			get_parent().get_parent().add_blood_splatter(local_pos)
		queue_free()
	pass


