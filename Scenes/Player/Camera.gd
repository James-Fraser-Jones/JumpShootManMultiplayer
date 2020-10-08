extends Camera

#radius
export var radMax : float = 5 #radius at which camera orbits around target
export var radSmoothing : float = 0.1

#offset
export var offsetMax : float = 2 #how high camera hovers above target object
export var offsetSmoothing : float = 0.1

#orientation
export var maxPitch : float = 90
export var minPitch : float = -90
export var oriSmoothing : float = 0.1
export var oriSensitivity : float = 0.15 #multiplier of raw mouse co-ordinates

#state
var rad : float = radMax
var offset : float = offsetMax
var ori : Vector2 = Vector2(0, deg2rad(-10)) #current orbit camera orientation in radians
var oriDebt : Vector2 = Vector2.ZERO #amount of rotation to apply to orientation in future (for camera smoothing)
var radTarget: float = radMax
var collisionRatio: float = 1
var target : Spatial #reference to target object

func _ready() -> void:
	target = get_parent()
	
func _input(event):
	if event is InputEventMouseMotion:
		oriDebt += event.relative * oriSensitivity

func _process(delta) -> void:
	#calculate orientation debt to pay this frame
	var xPaid : float = min_zero(oriDebt.x * delta / oriSmoothing, oriDebt.x)
	var yPaid : float = min_zero(oriDebt.y * delta / oriSmoothing, oriDebt.y)
	
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
	rotate_object_local(Vector3.UP, ori.x + deg2rad(180))
	rotate_object_local(Vector3.RIGHT, ori.y)
		
	setTranslation(delta, radTarget, collisionRatio)

func _physics_process(_delta: float) -> void:
	#cast ray and check for collision
	var idealPosition : Vector3 = target.translation + transform.basis.z * radMax
	var space_state = get_world().direct_space_state
	var result : Dictionary = space_state.intersect_ray(target.translation, idealPosition, [target])
	if result:
		#print(result.collider.get_name())
		var idealVector: Vector3 = idealPosition - target.translation
		var collisionVector: Vector3 = result.position - target.translation
		radTarget = collisionVector.length()
		collisionRatio = collisionVector.length() / idealVector.length()
	else: 
		radTarget = radMax
		collisionRatio = 1

func setTranslation(delta: float, radTarget: float, collisionRatio: float) -> void:
	var radDiff : float = radTarget - rad
	var z_paid : float = min_zero(radDiff * delta / radSmoothing, radDiff)
	rad += z_paid
	var offsetDiff : float = offsetMax * collisionRatio - offset
	var offset_paid : float = min_zero(offsetDiff * delta / offsetSmoothing, offsetDiff)
	offset += offset_paid
	translation = transform.basis.z * rad + Vector3.UP * offset

#return value closest to 0
func min_zero(a: float, b: float) -> float:
	if abs(a) <= abs(b):
		return a
	else:
		return b
