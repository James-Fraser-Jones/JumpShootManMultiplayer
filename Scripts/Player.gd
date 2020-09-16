extends RigidBody

export var acceleration : float = 40000
export var jumpForce : float = 300
export var cameraPath : NodePath

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
		add_central_force((Vector3(movement.x, 0, movement.y).normalized() * acceleration * delta).rotated(
		Vector3.UP, camera.camRotation.x))
		$MeshInstance.rotation.y = camera.camRotation.x #need linear interpolation here

func _input(event):
	if event.is_action_pressed("ui_select"):
		apply_central_impulse(Vector3.UP * jumpForce)
