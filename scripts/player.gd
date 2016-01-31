extends KinematicBody

var STATE_IDLE = 0
var STATE_RUNNING = 1
var STATE_JUMP = 2
var STATE_CASTING = 3
var STATE_ATTACK = 4
var STATE_START_SHOOTING = 5
var STATE_SHOOTING = 6
var STATE_END_SHOOTING = 7

### import the input helper class
var input_states = preload("input_states.gd")

### create input states classes
var state_up    = input_states.new("up")
var state_down  = input_states.new("down")
var state_left  = input_states.new("left")
var state_right = input_states.new("right")
var state_jump  = input_states.new("jump")
var state_shoot = input_states.new("shoot")
var state_attack= input_states.new("attack")
var state_penta = input_states.new("penta")
var state_1     = input_states.new("1")
var state_2     = input_states.new("2")
var state_3     = input_states.new("3")
var state_restart = input_states.new("restart")

################################3
var bullet_prototype = preload("res://scenes/bullet.scn")
var bullets_node = null

var gun_bullet_prototype = preload("res://scenes/gun_bullet.scn")
var gun_bullets_node = null

var buff_area_prototype = preload("res://scenes/arena.scn")
var buff_area_types = preload("buff_area_type.gd").new()
var buff_areas_node = null

var kameha_prototype = preload("res://scenes/kameha.scn")
var shell_prototype = preload("res://scenes/shell.scn")
var shell_node = null
#var buff_areas_node = null

var btn_up      = null
var btn_down    = null
var btn_left    = null
var btn_right   = null
var btn_jump    = null
var btn_attack  = null
var btn_shoot   = null
var btn_penta   = null
var btn_1       = null
var btn_2       = null
var btn_3       = null
var btn_restart = null

var is_in_buff_area = buff_area_types.NONE

var player_jump_hight = .7
var player_top_speed_vert = .3;
var player_top_speed_hori = .6;
var move_vector         = Vector3( 0, 0 ,0 )
var orientation         = 0

# sprites
var current_state = STATE_IDLE

var sprite_idle = null
var sprite_running = null
var sprite_jump = null
var sprite_casting = null
var sprite_sword_1 = null
var sprite_sword_2 = null
var sprite_gun = null
var sprite_shadow = null

var player_swor_area = null

# timeouts
var jump_timeout = -1
var buff_area_timeout = -1
var kameha_timeout = -1
var throw_cast_timeout = -1
var bullet_timeout = -1
var attack_timeout = -1
var bitting_timeout = -1
var gun_timeout = -1
var shooting_timeout = -1

var spawn_bullet_timeout = -1
var bullet_to_spawn = 0

# HP
var current_hp = 216
var biting_enemies = 0

# bloodv
var current_rounds = 8
var blood_level = 0
var spell_1_cost = 10#100
var spell_2_cost = 15#200
var spell_3_cost = 30#400

# func
func _fixed_process(delta):
	process_input()
	decrese_timeouts(delta)
	
	sprite_idle.set_flip_h(orientation)
	sprite_running.set_flip_h(orientation)
	sprite_jump.set_flip_h(orientation)
	sprite_casting.set_flip_h(orientation)
	sprite_sword_1.set_flip_h(orientation)
	sprite_sword_2.set_flip_h(orientation)
	sprite_gun.set_flip_h(orientation)
	
	var trans = player_swor_area.get_translation()
	if (orientation == 0):
		player_swor_area.set_translation(Vector3(4, trans.y, trans.z))
	else:
		player_swor_area.set_translation(Vector3(-4, trans.y, trans.z))
	
	# powrot do "trans.y = 0" po skakaniu
	if(current_state != STATE_JUMP && get_translation().y != 0 ):
		var trans = get_translation()
		set_translation(Vector3(trans.x, 0, trans.z))
	
	elif(throw_cast_timeout < 0 && attack_timeout < 0 && gun_timeout < 0 && current_state != STATE_SHOOTING):
		self.move( move_vector )
		if (current_state == STATE_JUMP):
			var trans = sprite_shadow.get_translation()
			sprite_shadow.set_translation(Vector3(trans.x, -get_translation().y, trans.z))

	biting()
	
	if(bullet_to_spawn > 0 && spawn_bullet_timeout < 0):
		bullet_to_spawn -= 1
		create_spermaskull()
		spawn_bullet_timeout = .2

func _ready():
	set_fixed_process(true)
	set_process_input(true)
	
	shell_node      = get_node("../shells")
	bullets_node    = get_node("../bullets")
	gun_bullets_node= get_node("../gun_bullets")
	buff_areas_node = get_node("../buff_areas")
	
	sprite_idle     = get_node("sprite_idle")
	sprite_jump     = get_node("sprite_jump")
	sprite_running  = get_node("sprite_running")
	sprite_casting  = get_node("sprite_casting")
	sprite_sword_1  = get_node("sprite_sword_1")
	sprite_sword_2  = get_node("sprite_sword_2")
	sprite_gun  	= get_node("sprite_gun")
	sprite_shadow  = get_node("shadow")
	
	player_swor_area = get_node("player_sword")
	pass

func process_input():
	btn_up    = state_up.check()
	btn_down  = state_down.check()
	btn_left  = state_left.check()
	btn_right = state_right.check()
	btn_jump  = state_jump.check()
	btn_shoot = state_shoot.check()
	btn_attack = state_attack.check()
	btn_penta = state_penta.check()
	btn_1 =     state_1.check()
	btn_2 =     state_2.check()
	btn_3 =     state_3.check()
	btn_restart = state_restart.check()
	
	var move = false
	move_vector = Vector3( 0, 0, 0 )
	
	if (current_hp <= 0):
		change_state(STATE_IDLE)
		if(btn_restart == 1):
			get_parent().restart()
		return
		
	if( btn_up   > 1 ):
		move_vector = Vector3(move_vector.x ,0 , -player_top_speed_vert )
		move = true
		
	if( btn_down > 1 ):
		move_vector = Vector3(move_vector.x ,0 , player_top_speed_vert )
		move = true
		
	if( btn_left  > 1 ):
		move_vector = Vector3(-player_top_speed_hori ,0 , move_vector.z )
		orientation = 1
		move = true
		
	if( btn_right > 1 ):
		move_vector = Vector3( player_top_speed_hori,0 , move_vector.z )
		orientation = 0
		move = true
		
	if(btn_jump == 1 && (current_state == STATE_RUNNING || current_state == STATE_IDLE)):
		change_state(STATE_JUMP)
		jump_timeout = 1
		
		
	if(current_state == STATE_JUMP):
		move_vector = Vector3(move_vector.x, cos((1 - jump_timeout) * PI) * player_jump_hight, move_vector.z)
		
	if (is_idle_or_running()):
		if (move):
			change_state(STATE_RUNNING)
		else:
			change_state(STATE_IDLE)
		
	if (btn_penta == 1 && buff_area_timeout < 0 && is_idle_or_running()):
		create_buff_area(1)
		buff_area_timeout = 4
		throw_cast_timeout = 1.5
		change_state(STATE_CASTING)
		
#	if (btn_shoot == 1 && is_idle_or_running()):
	if (btn_shoot == 1 && is_idle_or_running()):
		change_state(STATE_START_SHOOTING)
		sprite_gun.get_node("AnimationPlayer").play("fade_in")
		gun_timeout = .2
	
	if (btn_shoot == 3):# && current_state == STATE_SHOOTING):
		print(str("state ", current_state))
		change_state(STATE_END_SHOOTING)
		sprite_gun.get_node("AnimationPlayer").play("fade_out")
		gun_timeout = .2
	
	if (btn_3 == 1 && can_spell(3)):
		blood_level -= spell_3_cost
		create_kameha()
		kameha_timeout = 3 #10
		throw_cast_timeout = 1.5
		change_state(STATE_CASTING)
	
	if (btn_2 == 1 && can_spell(2)):
		blood_level -= spell_2_cost
		create_hand()
		throw_cast_timeout = 1.5
		change_state(STATE_CASTING)
		
	if (btn_1 == 1 && can_spell(1)):
		blood_level -= spell_1_cost
		bullet_to_spawn = 4
		create_spermaskull()
		spawn_bullet_timeout = .2
		throw_cast_timeout = 1.0
		change_state(STATE_CASTING)
		
	if (btn_attack == 1 && attack_timeout < 0 && is_idle_or_running()):
		change_state(STATE_ATTACK)
		try_hit_enemies()
		attack_timeout = .3
	
func is_idle_or_running():
	return current_state == STATE_IDLE || current_state == STATE_RUNNING
	
func decrese_timeouts(delta):
	if(buff_area_timeout > 0):
		buff_area_timeout -= delta
		
	if(bullet_timeout > 0):
		bullet_timeout -= delta
		
	if(spawn_bullet_timeout > 0):
		spawn_bullet_timeout -= delta
		
	if(gun_timeout > 0):
		gun_timeout -= delta
		if(gun_timeout < 0):
			if(current_state == STATE_START_SHOOTING):
				change_state(STATE_SHOOTING)
				sprite_gun.get_node("AnimationPlayer").play("shooting")
				create_gun_bullet()
				shooting_timeout = .3
			else:
				change_state(STATE_IDLE)
	
	if(shooting_timeout > 0):
		shooting_timeout -= delta
		if (shooting_timeout < 0 && current_state == STATE_SHOOTING):
			create_gun_bullet()
			shooting_timeout = .3
	
	if(attack_timeout > 0):
		attack_timeout -= delta
		if(attack_timeout<0):
			change_state(STATE_IDLE)
	
	if(throw_cast_timeout > 0):
		throw_cast_timeout -= delta
		if(throw_cast_timeout < 0):
			change_state(STATE_IDLE)
			
	if(jump_timeout > 0):
		jump_timeout -= delta
		if(jump_timeout < 0):
			change_state(STATE_IDLE)
				
	if(kameha_timeout > 0 && is_in_buff_area != buff_area_types.NONE):
		kameha_timeout -= delta
		
	if(bitting_timeout > 0):
		bitting_timeout -= delta

func set_is_in_buff_area(buff_area_type):
	is_in_buff_area = buff_area_type
	pass
	
func biting():
	if (bitting_timeout < 0 && biting_enemies > 0):
		current_hp -= biting_enemies * 5
		bitting_timeout = .3
		get_parent().add_blood_particle(get_translation())
#		print(str("hp ", current_hp))
	
func add_blood():
	blood_level += .5
#	print(str("bllod ", blood_level))
	
func can_spell(which_spell):
	if(which_spell == 1 && blood_level >= spell_1_cost):
		return true
		
	if(which_spell == 2 && blood_level >= spell_2_cost):
		return true
		
	if(which_spell == 3 && blood_level >= spell_3_cost):
		return true
	
	return false
	
func create_spermaskull():
	var bullet = bullet_prototype.instance()
	
	bullet.set_translation(self.get_translation() + Vector3(0,10,0))
	var bullet_velocity_x = 0
	if orientation == 0:
		bullet_velocity_x = .8
	else:
		bullet_velocity_x = -.8
	
	bullet.velocity = Vector3(bullet_velocity_x,0,0)
	bullet.target = get_random_enemies()
	bullet.get_node("Sprite3D").set_flip_h(orientation)
	bullets_node.add_child(bullet)
	pass
	
func get_random_enemies():
	var enemies = get_node("../enemies")
	if(enemies.get_child_count() > 0):
		return enemies.get_child(randi() % enemies.get_child_count())
	return null

func create_buff_area(buff_area_type):
	var buff_area = buff_area_prototype.instance()
	buff_area.type = 0
	buff_area.set_translation(self.get_translation() + Vector3(0, 0, -10))
	buff_areas_node.add_child(buff_area)
	pass
	
func create_kameha():
	var kameha = kameha_prototype.instance()
	kameha.set_translation(self.get_translation() + Vector3(0, 10, 0))
	var velocity_x = 0
	if orientation == 0:
		velocity_x = .8
	else:
		velocity_x = -.8
		
	kameha.velocity = Vector3(velocity_x, 0, 0)
	kameha.set_orientation( orientation )
	bullets_node.add_child(kameha)
	pass
	
func create_hand():
	for x in range(0, 3):
		var enemies = get_node("../enemies")
		if(enemies.get_child_count() <= x):
			break
		
		var enemy = enemies.get_child(x)
		enemy.next_state = 12 # freeze
		
		var hand = buff_area_prototype.instance()
		hand.type = 1
		hand.enemy = enemy
		hand.set_translation(enemy.get_translation() + Vector3(0, 0, 5))
		buff_areas_node.add_child(hand)
		get_parent().add_blood_particle(enemy.get_translation())
	pass
	
func create_gun_bullet():
	var gun_bullet = gun_bullet_prototype.instance()
	
	var multi = 0
	if(orientation == 1):
		multi = -1
	else:
		multi = 1
	
	var shell = shell_prototype.instance()
	shell.set_angular_velocity(Vector3(rand_range(-0.1,0.1),rand_range(-0.1,0.1),rand_range(-0.1,0.1)))
	shell.set_linear_velocity(Vector3(rand_range(-2,2),rand_range(-4,0.5),rand_range(-0.5,0.5)))
	shell.set_translation(self.get_translation() + Vector3(4.5*multi, 13.3+rand_range(-1,1), 0))
	shell_node.add_child(shell)
	
	gun_bullet.set_translation(self.get_translation() + Vector3(4*multi,13.3,0))
	var bullet_velocity_x = 0
	if orientation == 0:
		bullet_velocity_x = 1.8
	else:
		bullet_velocity_x = -1.8
	
	gun_bullet.velocity = Vector3(bullet_velocity_x,0,0)
	gun_bullet.get_node("Sprite3D").set_flip_h(orientation)
	gun_bullets_node.add_child(gun_bullet)
	pass
	
func change_state(new_state):
	current_state = new_state
	if(new_state == STATE_IDLE):
		sprite_idle.show()
		sprite_running.hide()
		sprite_jump.hide()
		sprite_casting.hide()
		sprite_sword_1.hide()
		sprite_sword_2.hide()
		sprite_gun.hide()
		
	elif(new_state == STATE_RUNNING):
		sprite_idle.hide()
		sprite_running.show()
		sprite_jump.hide()
		sprite_casting.hide()
		sprite_sword_1.hide()
		sprite_sword_2.hide()
		sprite_gun.hide()
		
	elif(new_state == STATE_JUMP):
		sprite_idle.hide()
		sprite_running.hide()
		sprite_jump.show()
		sprite_casting.hide()
		sprite_sword_1.hide()
		sprite_sword_2.hide()
		sprite_gun.hide()
		
	elif(new_state == STATE_CASTING):
		sprite_idle.hide()
		sprite_running.hide()
		sprite_jump.hide()
		sprite_casting.show()
		sprite_sword_1.hide()
		sprite_sword_2.hide()
		sprite_gun.hide()
		
	elif(new_state == STATE_ATTACK):
		sprite_idle.hide()
		sprite_running.hide()
		sprite_jump.hide()
		sprite_casting.hide()
		if(randi() % 4 != 0):
			sprite_sword_1.show()
			sprite_sword_2.hide()
		else:
			sprite_sword_1.hide()
			sprite_sword_2.show()
		sprite_gun.hide()
		
	elif(new_state == STATE_START_SHOOTING || new_state == STATE_SHOOTING || new_state == STATE_END_SHOOTING):
		sprite_idle.hide()
		sprite_running.hide()
		sprite_jump.hide()
		sprite_casting.hide()
		sprite_sword_1.hide()
		sprite_sword_2.hide()
		sprite_gun.show()
		

func _on_player_sword_area_enter( area ):
	if (area.get_name() == "area_enemy"):
		var node = area.get_node("../")
		node.in_sword_range = true
	pass


func _on_player_sword_area_exit( area ):
	if (area.get_name() == "area_enemy"):
		var node = area.get_node("../")
		node.in_sword_range = false
	pass
	
func try_hit_enemies():
	var enemies_node = get_node("../enemies")
	for child in enemies_node.get_children():
		child.sword_hit(get_node("player_sword").get_translation() + get_translation())
		
	pass


func _on_player_hit_box_area_enter( area ):
	if (area.get_name() == "area_enemy"):
		biting_enemies += 1
	pass


func _on_player_hit_box_area_exit( area ):
	if (area.get_name() == "area_enemy"):
		biting_enemies -= 1
	pass
