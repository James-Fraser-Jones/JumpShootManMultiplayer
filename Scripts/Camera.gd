extends Camera

export var radius : float = 10
export var targetPath : NodePath
export var lookSensitivity : float = 0.004
export var initAngle : float = -45

var target : Spatial

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	target = get_node(targetPath)
	rotate_object_local(Vector3.RIGHT, deg2rad(initAngle))
	updatePosition()

func _input(event) -> void:
	if event is InputEventMouseMotion:
		look(event.relative)

func _process(delta: float) -> void:
	updatePosition()

func look(mouseMovement: Vector2) -> void:
	var basis = transform.basis
	rotate(Vector3.UP, -mouseMovement.x * lookSensitivity)
	rotate_object_local(Vector3.RIGHT, -mouseMovement.y * lookSensitivity)
	orthonormalize() #correct for floating point error accumulation
	if rotation_degrees.z != 0: #clamp to hemi-circle (this needs to jump to max instead or something quarternions hmmm)
		transform.basis = basis

func updatePosition() -> void:
	translation = target.translation
	translate_object_local(Vector3.BACK * radius)

