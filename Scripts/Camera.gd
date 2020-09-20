extends Camera

#radius vars
export var maxRadius : float = 5 #radius at which camera orbits around target
export var radSmoothing : float = 0.5

#orientation vars
export var maxPitch : float = 90
export var initPitch : float = 45
export var minPitch : float = -90
export var oriSmoothing : float = 0.2 #how many seconds required to "catch up"
export var oriSensitivity : float = 0.2 #multiplier of raw mouse co-ordinates

#misc vars
export var yOffset : float = 2 #how high camera hovers above target object
export var margin : float = 0.1 #how far away camera stays from colliding objects

export var targetPath : NodePath

var rad : float = maxRadius

var ori : Vector2 = Vector2(0, deg2rad(-initPitch)) #current orbit camera orientation in radians
var oriDebt : Vector2 = Vector2.ZERO #amount of rotation to apply to orientation in future (for camera smoothing)

var target : Spatial #reference to target object

func _ready() -> void:
	target = get_node(targetPath)
	
func _input(event):
	if event is InputEventMouseMotion:
		oriDebt += event.relative * oriSensitivity

func _physics_process(delta):
	#calculate debt to pay this frame
	var xPaid : float = min_zero(oriDebt.x * delta / oriSensitivity, oriDebt.x)
	var yPaid : float = min_zero(oriDebt.y * delta / oriSensitivity, oriDebt.y)
	
	#pay debt into camOrientation
	ori.x = fposmod(ori.x - deg2rad(xPaid), deg2rad(360))
	ori.y = fmod(ori.y - deg2rad(yPaid), deg2rad(360))
	oriDebt.x -= xPaid
	oriDebt.y -= yPaid
	
	#clamp pitch
	if (ori.y < -deg2rad(maxPitch)):
		ori.y = -deg2rad(maxPitch)
		oriDebt.y = 0
	elif (ori.y > -deg2rad(minPitch)):
		ori.y = -deg2rad(minPitch)
		oriDebt.y = 0
	
	#update transform with new camera orientation
	transform.basis = Basis()
	rotate_object_local(Vector3.UP, ori.x)
	rotate_object_local(Vector3.RIGHT, ori.y)
	
	#cast ray and check for collision
	var idealPosition : Vector3 = target.translation + transform.basis.z * maxRadius
	var space_state = get_world().direct_space_state
	var result : Dictionary = space_state.intersect_ray(target.translation, idealPosition, [target])
	if result:
		var collisionVector: Vector3 = result.position - target.translation
		var idealVector: Vector3 = idealPosition - target.translation
		var collisionRatio: float = collisionVector.length() / idealVector.length()
		setTranslation(delta, collisionVector.length(), result.normal * margin, collisionRatio)
	else: setTranslation(delta, maxRadius, Vector3.ZERO, 1)

func setTranslation(delta: float, radTarget: float, marginVector: Vector3, collisionRatio: float) -> void:
	var radDiff : float = radTarget - rad
	var z_paid : float = min_zero(radDiff * delta / radSmoothing, radDiff)
	rad += z_paid
	translation = target.translation + (transform.basis.z * rad) + marginVector + (Vector3.UP * yOffset * collisionRatio)

#return value closest to 0
func min_zero(a: float, b: float) -> float:
	if abs(a) <= abs(b):
		return a
	else:
		return b
