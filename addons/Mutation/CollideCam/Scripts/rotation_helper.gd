extends Spatial

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var cam_ray
var Cam
var is_zoomed


func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	is_zoomed = false
	cam_ray = get_child(3)
	Cam = get_child(0)
	pass

func _process(delta):
	cam_ray.force_raycast_update()
	
	if is_zoomed:
		cam_ray.cast_to = $CamPos_Zoom.transform.origin
	else:
		cam_ray.cast_to = $CamPos_Default.transform.origin
	
	if Input.is_action_just_pressed("aim_zoom"):
		is_zoomed = true
	if Input.is_action_just_released("aim_zoom"):
		is_zoomed = false
	
	if cam_ray.is_colliding():
		Cam.global_transform.origin = cam_ray.get_collision_point()
	else:
		if is_zoomed:
			Cam.global_transform.origin = $CamPos_Zoom.global_transform.origin
		else:
			Cam.global_transform.origin = $CamPos_Default.global_transform.origin
	pass
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
