extends RigidBody

export var runForce : float = 40000
export var jumpForce : float = 300
export var cameraPath : NodePath
export var rotationSpeed : float = 10

var camera : Camera

#vars for linear interpolation of y-axis rotation as character moves
var rotationWeight : float = 1
var oldRotation : Quat
var targetRotation : Quat

func _ready() -> void:
	camera = get_node(cameraPath)

func _physics_process(delta: float) -> void:
	var movement : Vector2 = Vector2.ZERO
	if Input.is_action_pressed("ui_left"): movement.x -= 1
	if Input.is_action_pressed("ui_right"): movement.x += 1
	if Input.is_action_pressed("ui_up"): movement.y -= 1
	if Input.is_action_pressed("ui_down"): movement.y += 1
	if movement != Vector2.ZERO:
		add_central_force((Vector3(movement.x, 0, movement.y).normalized() * runForce * delta).rotated(
			Vector3.UP, camera.camRotation.x))
		handleRotation(movement)
		
func _process(delta: float) -> void:
	if rotationWeight < 1:
		rotationWeight = min(1, rotationWeight + rotationSpeed * delta)
		$MeshInstance.transform.basis = Basis(oldRotation.slerp(targetRotation, rotationWeight))

func _input(event):
	if event.is_action_pressed("ui_select"):
		apply_central_impulse(Vector3.UP * jumpForce)

func handleRotation(movement: Vector2) -> void:
	#NOTE: the first rotation "rotated(Vector3.RIGHT, deg2rad(-90))" is only necessary
	#to counteract the fact that I have to rotate the MeshInstance by -90 in the x axis
	#to get the correct orientation for the pill shape
	var newRotation = Quat(Basis().rotated(Vector3.RIGHT, deg2rad(-90)).rotated(Vector3.UP,
		camera.camRotation.x - movement.angle() - deg2rad(90)))
	if newRotation != targetRotation:
		oldRotation = Quat($MeshInstance.transform.basis)
		targetRotation = newRotation
		rotationWeight = 0

#just found out about lerp_angle()
func modularMinDistance(from: float, to: float, mod: float) -> float:
	var rot : float = fposmod(to, mod) - fposmod(from, mod)
	var alt : float = rot - mod * sign(rot)
	if abs(rot) <= abs(alt):
		return rot
	else:
		return alt
