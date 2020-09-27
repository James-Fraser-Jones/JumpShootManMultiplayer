extends KinematicBody

export var speed : float = 10
export var gravity : float = 9.8
export var jump : float = 10

var velocity : Vector3 = Vector3.ZERO

func _physics_process(delta: float) -> void:
	var arrows : Vector2 = Vector2.ZERO
	if Input.is_action_pressed("ui_left"): arrows.x -= 1
	if Input.is_action_pressed("ui_right"): arrows.x += 1
	if Input.is_action_pressed("ui_up"): arrows.y -= 1
	if Input.is_action_pressed("ui_down"): arrows.y += 1
	var flatMovement : Vector2 = arrows.normalized().rotated(-$Camera.ori.x + PI) * speed
	var movement : Vector3 = Vector3(flatMovement.x, 0, flatMovement.y)
	#velocity.y -= gravity * delta
	if Input.is_action_just_pressed("ui_accept"):
		velocity.y += jump
	var dMovement : Vector3 = (movement + velocity) * delta
	var collision : KinematicCollision = move_and_collide(dMovement, true, true, true)
	if collision:
		print(rad2deg(collision.normal.angle_to(Vector3.UP)))
		dMovement = dMovement.slide(collision.normal)
		velocity = velocity.slide(collision.normal)
	transform.origin += dMovement
	#currently still phasing through shit, slipperyness seems to work nicely though
	#also need to make it that movement can actually be used to reduce forces working against
	#it but only based on some kind of deceleration constant and speed
	#and movement can't be used to increase these kinds of forces, only reduce them
	#and movement doesn't actually apply until these "working against" forces are gone in that direction

