
extends RigidBody

var timeout = 0
var bounce =0

func _ready():
	set_fixed_process(true)
	pass
func _fixed_process(delta):
	
	timeout+=delta
	if (timeout>1):
		if (bounce <1 ):
			timeout = 0.4+rand_range(0.0 ,0.2)
			bounce+=1
			get_node("SamplePlayer").play("shells")
		elif (bounce <2):
			timeout = 0.8+rand_range(0.0 ,0.1)
			bounce+=1
			get_node("SamplePlayer").play("shells")
		else:
			set_fixed_process(false)
			get_node("SamplePlayer").play("shells")


