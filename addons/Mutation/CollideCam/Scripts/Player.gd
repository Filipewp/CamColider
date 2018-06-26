extends KinematicBody

#Basic variables for movement
var speed = 800
var direction = Vector3()
var gravity = -9.8
var velocity = Vector3()
var camera
var camLook_point
var hit_point
#Life counter
var life = 100
var alive = true



# Cooldown
var last_shot = 0.0
var fire_rate = 0.3


var particula_temp
var part_tiro_emitTime = 0.0

var enemy
var enemyPos

var mouse_sensitivity = 0.15
var camera_angle = 0

#Execute only 1 time
func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	enemy = get_parent().get_node('Beginner_Enemy')
	camera = $rotation_helper/Camera
	camLook_point = $aim_point
	hit_point = $rotation_helper/Camera/shot_range
	
	pass

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
		
		var change = event.relative.y * mouse_sensitivity
		if change + camera_angle < 60 and change + camera_angle > -30:
			$rotation_helper.rotate_x(deg2rad(change))
			camera_angle += change
	pass

#Execute every frame / Execute all common methods
func _process(delta):
	
	part_tiro_emitTime -= delta
	last_shot -= delta
	#if(enemy.alive):
	#	enemyPos = enemy.transform.origin
	
	#If our player is alive
	if alive:
		hit_point.force_raycast_update()
		camLook_point.translation = hit_point.get_collision_point()
		#$particula.global_transform.origin = camLook_point.global_transform.origin
		
		#print($particula.global_transform.origin.x)
		camera.look_at(camLook_point.translation, Vector3(0, 1, 0))
		move(delta)
		jump()
		if Input.is_action_pressed("shoot"):
			if last_shot < 0:
				Ray_Shoot()
				last_shot = fire_rate
	#DEBUG

#Execute every frame / Execute all physics methods
func _physics_process(delta):
	
	#If our player is alive
	if alive:
		collisions()

#Move our player
func move(delta):
	
	#Restart movement
	direction = Vector3(0,0,0)
	
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	var aim = $rotation_helper/Camera.get_global_transform().basis
	
	#Set our player direction
	if Input.is_action_pressed("ui_down"):
		direction += aim.z
	if Input.is_action_pressed("ui_up"):
		direction -= aim.z
	if Input.is_action_pressed("ui_left"):
		direction -= aim.x
	if Input.is_action_pressed("ui_right"):
		direction += aim.x
	
	if Input.is_action_pressed('Active_Alfa'):
		enemy.active = true
	#Normalize our movement
	direction = direction.normalized()
	
	#Set speed
	direction = direction * speed * delta
	
	#Check if our player jumped
	if velocity.y > 0:
		gravity = -20
	else:
		gravity = -30
	
	#Update velocity
	velocity.y += gravity * delta
	velocity.x = direction.x
	velocity.z = direction.z
	
	#Make our player move
	velocity = move_and_slide(velocity, Vector3(0,1,0))

#Make our player jump
func jump():
	
	#If player it's on floor and 'Space' got pressed
	if is_on_floor() and Input.is_key_pressed(KEY_SPACE):
		
		#Jump!
		velocity.y = 10

#Check collisions
func collisions():
	
	#Get number of collisions
	var hitCount = get_slide_count()
	
	#If there is any
	if hitCount > 0:
		
		#Get the first
		var collision = get_slide_collision(0)
		
		#If it's and Object
		if collision.collider is RigidBody:
			
			damage(10)
			
			#Push him
			collision.collider.apply_impulse(collision.position, -collision.normal)

#Check if receive damage
func damage(damage):
	
	life -= damage
	print(life)
	if life <= 0:
		
		#Show to everyone that we died
		alive = false
		
		#Hide our player from 'Scene'
		hide()

	
func Ray_Shoot():
	if hit_point.is_colliding():
		var temp_obj = hit_point.get_collider()
		part_tiro_emitTime = 0.1
		$out_bullet/shot_particle.show()
		$emitter/particula.show()
		
		if temp_obj is RigidBody:
			var normalTiro = (temp_obj.translation - $aim_point.translation).normalized()
			temp_obj.apply_impulse(temp_obj.translation, normalTiro)
		
		if temp_obj is KinematicBody:
			var normalTiro = (temp_obj.translation - $aim_point.translation).normalized()
			temp_obj.translate(normalTiro)
			if temp_obj.has_method("get_hit"):
				temp_obj.get_hit()