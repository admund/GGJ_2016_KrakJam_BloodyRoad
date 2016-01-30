
extends KinematicBody

var target = null
var velocity = Vector3(0,0,0)
var timeout = 0

func _ready():
	set_fixed_process(true)

func _fixed_process(delta):
	timeout += delta
	if (timeout>2):
		delete()
	
	if (target == null):
		move( velocity )
	else:
		if(target.current_state == 10):
			target = null
		else:
			var vect = target.get_translation() - get_translation();
			move( vect.normalized() )

func delete():
	queue_free()
