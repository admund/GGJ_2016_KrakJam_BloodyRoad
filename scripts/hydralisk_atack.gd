
extends Sprite3D

var timer = 0

func _ready():
	set_fixed_process(true)
	get_node("AnimationPlayer").play("attack")
	pass

func _fixed_process(delta):
	timer+=delta
	if (timer>=1):
		set_modulate(Color(1,1,1,1-(timer-1)*2))
	if (timer>1.5):
		queue_free()


