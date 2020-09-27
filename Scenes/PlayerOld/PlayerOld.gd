extends KinematicBody

export var rotationSpeed : float = 10
export var gravity : float = 10
export var speed : float = 8
export var sprint_speed_scalar : float = 1.5
export var jump_speed: float = 10

var initRotation : float

var oldRotation : float
var newRotation : float
var rotationWeight : float = 1
var sprintDirection : bool = false
var sprinting : bool = false
var velocity : Vector3 = Vector3.ZERO
var slipping : bool = false

func _ready() -> void:
	initRotation = rotation.y

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("sprint"):
		if sprinting:
			sprinting = false
		else:
			if sprintDirection:
				sprinting = true

func _physics_process(delta: float) -> void:
	var arrows : Vector2 = Vector2.ZERO
	if Input.is_action_pressed("ui_left"): arrows.x -= 1
	if Input.is_action_pressed("ui_right"): arrows.x += 1
	if Input.is_action_pressed("ui_up"): arrows.y -= 1
	if Input.is_action_pressed("ui_down"): arrows.y += 1
	sprintDirection = arrows.y == -1
	if !sprintDirection: sprinting = false	
	arrows = arrows.normalized().rotated(-$Camera.ori.x + PI - initRotation) * (sprint_speed_scalar if sprinting else 1) * speed
	
	if arrows != Vector2.ZERO:
		handleRotation(arrows)
		pass
		
	#var test_vel : Vector3 = velocity
	#test_vel.x = arrows.x
	#test_vel.z = arrows.y		
	#test_move(transform, -test_vel)
	#var lastCollision : KinematicCollision = get_slide_collision(0)
	#if lastCollision:
	#	var ang : float = Vector3.UP.angle_to(lastCollision.normal)
	#	print(lastCollision.normal)
	#	#print(rad2deg(ang))
	#	arrows *= cos(ang) #jumps between 1 and 0 too much when walking into walls
	
	velocity.x = arrows.x
	velocity.z = arrows.y
	
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity += Vector3.UP * jump_speed #how to add "impulses"
	velocity += Vector3.DOWN * gravity * delta #how to add "forces"
	
	#var oldTransform : Transform = transform
	velocity = move_and_slide(velocity, Vector3.UP, true)
	#slipping = !is_on_floor() and get_slide_count() > 0
	#if slipping:
	#	transform.origin.y = min(transform.origin.y, oldTransform.origin.y)

func _process(delta: float) -> void:
	if rotationWeight < 1:
		rotationWeight = min(1, rotationWeight + rotationSpeed * delta)
		$MeshInstance.rotation.y = lerp_angle(oldRotation, newRotation, rotationWeight)

func handleRotation(arrows: Vector2) -> void:
	var rot = -(arrows.angle() + initRotation + PI/2)
	if rot != newRotation:
		oldRotation = $MeshInstance.rotation.y
		newRotation = rot
		rotationWeight = 0
