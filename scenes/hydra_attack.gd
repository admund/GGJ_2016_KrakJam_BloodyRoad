
extends Area

var timer = 0

func _ready():
	set_fixed_process(true)
	pass

func _fixed_process(delta):
	timer+=delta
	
	if (timer>0.5):
		queue_free()
