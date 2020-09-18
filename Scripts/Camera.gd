extends Camera

export var radius : float = 5
export var verticalSensitivity : float = 0.004
export var horizontalSensitivity : float = 0.004
export var minPitch : float = -90
export var maxPitch : float = 90
export var initPitch : float = 45
export var yOffset : float = 2
export var margin : float = 0.2
export var targetPath : NodePath

var camRotation : Vector2 = Vector2(0, deg2rad(-initPitch))
var target : Spatial

func _ready() -> void:
	target = get_node(targetPath)
	
func _input(event):
	if event is InputEventMouseMotion:
		camRotation.x = fposmod(camRotation.x - event.relative.x * horizontalSensitivity
			, deg2rad(360))
		camRotation.y = clamp(fmod(camRotation.y - event.relative.y * verticalSensitivity
			, deg2rad(360))
			, deg2rad(-maxPitch), deg2rad(-minPitch))

func _physics_process(delta):
	#need to impose an artifical max rotational speed per physics frame
	#include delta in order to more evenly distribute rotation across frames
	
	#update rotation
	transform.basis = Basis()
	rotate_object_local(Vector3.UP, camRotation.x)
	rotate_object_local(Vector3.RIGHT, camRotation.y)
	
	#set up positions
	var orbitPosition : Vector3 = target.translation + Vector3.UP * yOffset
	var camPosition : Vector3 = orbitPosition + transform.basis.z * radius
	
	#cast ray and check for collision
	var space_state = get_world().direct_space_state
	var result : Dictionary = space_state.intersect_ray(orbitPosition, camPosition, [target])
	if result: camPosition = result.position + result.normal * margin
	
	#apply translation
	translation = camPosition
