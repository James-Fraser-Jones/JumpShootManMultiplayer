extends Camera

export var radius : float = 10
export var targetPath : NodePath
export var lookSensitivity : float = 0.004
export var initAngle : float = -45

var camRotation : Vector2 = Vector2(0, deg2rad(initAngle))
var target : Spatial

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	target = get_node(targetPath)
	updateRotation()
	
func _input(event):
	if event is InputEventMouseMotion:
		camRotation.x = fposmod(camRotation.x - event.relative.x * lookSensitivity, deg2rad(360))
		camRotation.y = clamp(fmod(camRotation.y - event.relative.y * lookSensitivity, deg2rad(360))
			, deg2rad(-90), deg2rad(90))
		updateRotation()

func _process(delta: float) -> void:
	updatePosition()

func updateRotation() -> void:
	transform.basis = Basis()
	rotate_object_local(Vector3.UP, camRotation.x)
	rotate_object_local(Vector3.RIGHT, camRotation.y)

func updatePosition() -> void:
	translation = target.translation
	translate_object_local(Vector3.BACK * radius)


