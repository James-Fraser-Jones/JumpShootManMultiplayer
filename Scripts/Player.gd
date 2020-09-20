extends RigidBody

export var runForce : float = 40000
export var jumpForce : float = 300
export var rotationSpeed : float = 10
export var cameraPath : NodePath

#vars for linear interpolation of y-axis rotation as character moves
var rotationWeight : float = 1
var oldRotation : float
var newRotation : float

var camera : Camera

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
			Vector3.UP, camera.ori.x))
		handleRotation(movement)
		
func _process(delta: float) -> void:
	if rotationWeight < 1:
		rotationWeight = min(1, rotationWeight + rotationSpeed * delta)
		$MeshInstance.rotation.y = lerp_angle(oldRotation, newRotation, rotationWeight)

func _input(event):
	if event.is_action_pressed("ui_select"):
		apply_central_impulse(Vector3.UP * jumpForce)

func handleRotation(movement: Vector2) -> void:
	var rot = camera.ori.x - movement.angle() - deg2rad(90)
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
