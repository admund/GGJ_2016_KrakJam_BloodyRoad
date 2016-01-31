
extends Sprite3D

var timer = 0
var shell_prototype = preload("res://scenes/debri.scn")
var shell_node = null
func _ready():
	set_fixed_process(true)
	get_node("AnimationPlayer").play("attack")
	shell_node      = get_node("../../../shells")
	var shell = shell_prototype.instance()
	shell.set_angular_velocity(Vector3(rand_range(-0.1,0.1),rand_range(-0.1,0.1),rand_range(-0.1,0.1)))
	shell.set_linear_velocity(Vector3(rand_range(-5,5),rand_range(20,50),rand_range(-5,5)))
	shell.set_translation(self.get_translation() + Vector3(0, 1, 0))
	get_node("Particles").set_emitting(true)
	shell_node.add_child(shell)
	pass

func _fixed_process(delta):
	timer+=delta
	if (timer>=1):
		set_modulate(Color(1,1,1,1-(timer-1)*2))
	if (timer>1.5):
		queue_free()


