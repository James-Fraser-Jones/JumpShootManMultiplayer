extends RigidBody

export var speed : float = 4000
export var jump : float = 1400
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
		add_central_force((Vector3(movement.x, 0, movement.y).normalized() * speed * delta).rotated(
		Vector3.UP, camera.camRotation.x))
		$MeshInstance.rotation.y = camera.camRotation.x #need linear interpolation here

func _input(event):
	if event.is_action_pressed("ui_select"):
	   add_central_force(Vector3.UP * jump)
