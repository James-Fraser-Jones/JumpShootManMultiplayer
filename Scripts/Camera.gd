extends Camera

export var radius : float = 5
export var verticalSensitivity : float = 0.004
export var horizontalSensitivity : float = 0.004
export var minPitch : float = -90
export var maxPitch : float = 90
export var initPitch : float = 45
export var yOffset : float = 2
export var targetPath : NodePath

var camRotation : Vector2 = Vector2(0, deg2rad(-initPitch))
var target : Spatial

func _ready() -> void:
	target = get_node(targetPath)
	updateRotation()
	
func _input(event):
	if event is InputEventMouseMotion:
		camRotation.x = fposmod(camRotation.x - event.relative.x * horizontalSensitivity, deg2rad(360))
		camRotation.y = clamp(fmod(camRotation.y - event.relative.y * verticalSensitivity, deg2rad(360))
			, deg2rad(-maxPitch), deg2rad(-minPitch))
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
	translation.y += yOffset


