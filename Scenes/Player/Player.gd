extends KinematicBody

var rotationSpeed : float = 10
var rotationWeight : float = 1
var oldRotation : float
var newRotation : float

var gravity : float = 9.8
var speed : float = 8
var jump_speed: float = 6
var unclimbable_angle: float = deg2rad(50)

var velocity : Vector3 = Vector3.ZERO

func _physics_process(delta: float) -> void:
	var arrows : Vector2 = Vector2.ZERO
	if Input.is_action_pressed("ui_left"): arrows.x -= 1
	if Input.is_action_pressed("ui_right"): arrows.x += 1
	if Input.is_action_pressed("ui_up"): arrows.y -= 1
	if Input.is_action_pressed("ui_down"): arrows.y += 1
	arrows = arrows.normalized().rotated(-$Camera.ori.x) * speed
	
	if arrows != Vector2.ZERO:
		handleRotation(arrows)
		
	var test_vel : Vector3 = velocity
	test_vel.x = arrows.x
	test_vel.z = arrows.y		
	test_move(transform, -test_vel)
	var lastCollision : KinematicCollision = get_slide_collision(0)
	if lastCollision:
		var ang : float = Vector3.UP.angle_to(lastCollision.normal) #print(rad2deg(ang))
		if ang > unclimbable_angle:
			#what to do here?
			pass
		arrows *= cos(ang)
		
	velocity.x = arrows.x
	velocity.z = arrows.y
	
	if Input.is_action_just_pressed("ui_accept"):
		velocity += Vector3.UP * jump_speed #how to add "impulses"
		print("jump")
	velocity += Vector3.DOWN * gravity * delta #how to add "forces"
	
	velocity = move_and_slide(velocity, Vector3.UP, true)

func _process(delta: float) -> void:
	if rotationWeight < 1:
		rotationWeight = min(1, rotationWeight + rotationSpeed * delta)
		$MeshInstance.rotation.y = lerp_angle(oldRotation, newRotation, rotationWeight)

func handleRotation(arrows: Vector2) -> void:
	var rot = -arrows.angle() - deg2rad(90)
	if rot != newRotation:
		oldRotation = $MeshInstance.rotation.y
		newRotation = rot
		rotationWeight = 0
