extends Camera

export var radius : float = 5 #radius at which camera orbits around target
export var minPitch : float = -90
export var maxPitch : float = 90
export var initPitch : float = 45
export var yOffset : float = 2 #how high camera hovers above target object
export var margin : float = 0.1 #how far away camera stays from colliding objects
export var cameraSmoothing : float = 0.4 #how many seconds required to "catch up"
export var cameraSensitivity : float = 0.2 #multiplier of raw mouse co-ordinates
export var targetPath : NodePath

var camDebt : Vector2 = Vector2.ZERO #record of amount of rotation to apply in future (for camera smoothing)
var camRotation : Vector2 = Vector2(0, deg2rad(-initPitch)) #orbit camera rotation in radians
var target : Spatial #reference to target object
var distance : float = 1 #how far away camera is from target due to clipping behavior

func _ready() -> void:
	target = get_node(targetPath)
	
func _input(event):
	if event is InputEventMouseMotion:
		camDebt += event.relative * cameraSensitivity

func _physics_process(delta):
	#calculate debt to pay this frame
	var xPaid : float = min_zero(camDebt.x * (delta / cameraSmoothing), camDebt.x)
	var yPaid : float = min_zero(camDebt.y * (delta / cameraSmoothing), camDebt.y)
	
	#pay debt into camRotation
	camDebt.x -= xPaid
	camDebt.y -= yPaid
	camRotation.x = fposmod(camRotation.x - deg2rad(xPaid), deg2rad(360))
	camRotation.y = fmod(camRotation.y - deg2rad(yPaid), deg2rad(360))
	
	#clamp pitch
	if (camRotation.y < -deg2rad(maxPitch)):
		camRotation.y = -deg2rad(maxPitch)
		camDebt.y = 0
	elif (camRotation.y > -deg2rad(minPitch)):
		camRotation.y = -deg2rad(minPitch)
		camDebt.y = 0
	
	#update transform with new camRotation
	transform.basis = Basis()
	rotate_object_local(Vector3.UP, camRotation.x)
	rotate_object_local(Vector3.RIGHT, camRotation.y)
	
	#cast ray and check for collision
	var camPosition : Vector3 = target.translation + transform.basis.z * radius
	var space_state = get_world().direct_space_state
	var result : Dictionary = space_state.intersect_ray(target.translation, camPosition, [target])
	if result: 
		distance = (result.position - target.translation).length() / (camPosition - target.translation).length()
		camPosition = result.position + result.normal * margin
	else: distance = 1
	
	#apply yOffset and translation
	camPosition += Vector3.UP * yOffset * distance
	translation = camPosition

#return value closest to 0
func min_zero(a: float, b: float) -> float:
	if abs(a) <= abs(b):
		return a
	else:
		return b
