extends RigidBody

export var runForce : float = 100000
export var maxSpeed : float = 7
export var rotationSpeed : float = 10

export var jumpForce : float = 300

export var cameraPath : NodePath

#vars for linear interpolation of y-axis rotation as character moves
var rotationWeight : float = 1
var oldRotation : float
var newRotation : float

var camera : Camera

func _ready() -> void:
	camera = get_node(cameraPath)

func _physics_process(delta: float) -> void:
	var arrows : Vector2 = Vector2.ZERO
	if Input.is_action_pressed("ui_left"): arrows.x -= 1
	if Input.is_action_pressed("ui_right"): arrows.x += 1
	if Input.is_action_pressed("ui_up"): arrows.y -= 1
	if Input.is_action_pressed("ui_down"): arrows.y += 1
	if arrows != Vector2.ZERO:
		var moveVector : Vector2 = arrows.normalized().rotated(-camera.ori.x) * runForce
		var velocityVector = Vector2(linear_velocity.x, linear_velocity.z)
		var ang : float = moveVector.angle_to(velocityVector)
		if ang > -PI/2 and ang < PI/2 and velocityVector.length() >= maxSpeed:
			moveVector = moveVector.project(velocityVector.rotated(PI/2))
		add_central_force(Vector3(moveVector.x, 0, moveVector.y) * delta)
		handleRotation(arrows)
		#print(velocityVector.length())
		
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

#just found out about lerp_angle()
func modularMinDistance(from: float, to: float, mod: float) -> float:
	var rot : float = fposmod(to, mod) - fposmod(from, mod)
	var alt : float = rot - mod * sign(rot)
	if abs(rot) <= abs(alt):
		return rot
	else:
		return alt
