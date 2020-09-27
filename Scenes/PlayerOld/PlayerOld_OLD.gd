extends RigidBody

#const WALK_ACCEL = 500.0
#const WALK_DEACCEL = 500.0
#const AIR_ACCEL = 100.0
#const AIR_DEACCEL = 100.0
#const MAX_VELOCITY = 140.0
#const JUMP_VELOCITY = 380

#export var runForce : float = 100000
#export var maxSpeed : float = 7
export var speed : float = 10
#var moveVector : Vector2 = Vector2.ZERO

export var jumpForce : float = 300
export var rotationSpeed : float = 10
export var cameraPath : NodePath
var rotationWeight : float = 1
var oldRotation : float
var newRotation : float
var camera : Camera

func _ready() -> void:
	camera = get_node(cameraPath)

func _physics_process(delta: float) -> void:
	add_central_force(Vector3.UP*0.00001) #ensure _integrate_forces is called every update
	#var arrows : Vector2 = Vector2.ZERO
	#if Input.is_action_pressed("ui_left"): arrows.x -= 1
	#if Input.is_action_pressed("ui_right"): arrows.x += 1
	#if Input.is_action_pressed("ui_up"): arrows.y -= 1
	#if Input.is_action_pressed("ui_down"): arrows.y += 1
	
	#if arrows != Vector2.ZERO:
	#	handleRotation(arrows)
	
	#var newMoveVector : Vector2 = arrows.normalized().rotated(-camera.ori.x) * speed
	#var correctiveImpulse : Vector2 = newMoveVector 
	#if moveVector != Vector2.ZERO:
	#	var remainingVelocity : Vector2 = Vector2(linear_velocity.x, linear_velocity.z).project(moveVector)
	#	correctiveImpulse -= remainingVelocity.normalized() * clamp(remainingVelocity.length(), 0, moveVector.length())
	#apply_central_impulse(Vector3(correctiveImpulse.x, 0, correctiveImpulse.y) * mass)
	#moveVector = newMoveVector
	pass
	
func _integrate_forces(state: PhysicsDirectBodyState) -> void:
	var arrows : Vector2 = Vector2.ZERO
	if Input.is_action_pressed("ui_left"): arrows.x -= 1
	if Input.is_action_pressed("ui_right"): arrows.x += 1
	if Input.is_action_pressed("ui_up"): arrows.y -= 1
	if Input.is_action_pressed("ui_down"): arrows.y += 1
	if arrows != Vector2.ZERO:
		handleRotation(arrows)
		
	var moveVector : Vector2 = arrows.normalized().rotated(-camera.ori.x) * speed * state.step
	state.transform.origin += Vector3(moveVector.x, 0, moveVector.y)
	
	print(linear_velocity)
	
	#var newMoveVector : Vector2 = arrows.normalized().rotated(-camera.ori.x) * speed
	#var moveImpulse : Vector2 = newMoveVector
	#if moveVector != Vector2.ZERO:
		#var remainingVelocity : Vector2 = Vector2(state.linear_velocity.x, state.linear_velocity.z).project(moveVector)
		#var correctiveImpulse : Vector2 = remainingVelocity.normalized() * clamp(remainingVelocity.length(), 0, moveVector.length())
		##either two lines above or below
		#var x = moveVector.dot(Vector2(state.linear_velocity.x, state.linear_velocity.z).normalized())
		#var correctiveImpulse = moveVector.normalized() * max(0, x)
		#moveImpulse -= correctiveImpulse
	#changeVelocity(state, moveImpulse)
	#moveVector = newMoveVector
	
	#if arrows != Vector2.ZERO:
		#var moveVector : Vector2 = arrows.normalized().rotated(-camera.ori.x) * runForce
		#var velocityVector = Vector2(linear_velocity.x, linear_velocity.z)
		#var ang : float = moveVector.angle_to(velocityVector)
		#if ang > -PI/2 and ang < PI/2 and velocityVector.length() >= maxSpeed:
		#	moveVector = moveVector.project(velocityVector.rotated(PI/2))
		#add_central_force(Vector3(moveVector.x, 0, moveVector.y) * delta)
		#handleRotation(arrows)
	
	if Input.is_action_just_pressed("ui_page_down"):
		state.apply_central_impulse(Vector3.FORWARD * 20 * mass)

func _process(delta: float) -> void:
	if rotationWeight < 1:
		rotationWeight = min(1, rotationWeight + rotationSpeed * delta)
		$MeshInstance.rotation.y = lerp_angle(oldRotation, newRotation, rotationWeight)

func _input(event: InputEvent):
	if event.is_action_pressed("ui_select"):
		apply_central_impulse(Vector3.UP * jumpForce)

func handleRotation(arrows: Vector2) -> void:
	var rot = camera.ori.x - arrows.angle() - deg2rad(90)
	if rot != newRotation:
		oldRotation = $MeshInstance.rotation.y
		newRotation = rot
		rotationWeight = 0
		
#func setVelocity(state: PhysicsDirectBodyState, velocity: Vector2) -> void:
#	state.apply_central_impulse((Vector3(velocity.x, 0, velocity.y) - linear_velocity) * mass)

#func changeVelocity(state: PhysicsDirectBodyState, velocity: Vector2) -> void:
#	state.apply_central_impulse(Vector3(velocity.x, 0, velocity.y) * mass)

#func modularMinDistance(from: float, to: float, mod: float) -> float:
#	var rot : float = fposmod(to, mod) - fposmod(from, mod)
#	var alt : float = rot - mod * sign(rot)
#	if abs(rot) <= abs(alt):
#		return rot
#	else:
#		return alt
