extends KinematicBody

export var max_slides : int = 5

export var speed : float = 10
export var jump_height : float = 8
export var max_jumps : int = 1
export var gravity : float = 15

export var floor_horiz_decay : float = 0.05
export var air_horiz_decay : float = 0.5
export var air_vert_decay : float = 0.95

export var max_floor_angle : float = deg2rad(45)
export var fast_climbing : bool = false

var velocity : Vector3 = Vector3.ZERO
var forces : Array = []
var on_floor : bool = false
var num_jumps : int = max_jumps
var jumping : bool = false

func _ready() -> void:
	forces.append(Vector3.DOWN * gravity)

func _physics_process(delta: float) -> void:
	var arrows : Vector2 = Vector2.ZERO
	if Input.is_action_pressed("ui_left"): arrows.x -= 1
	if Input.is_action_pressed("ui_right"): arrows.x += 1
	if Input.is_action_pressed("ui_up"): arrows.y -= 1
	if Input.is_action_pressed("ui_down"): arrows.y += 1
	var flatMovement : Vector2 = arrows.normalized().rotated(-$Camera.ori.x + PI) * speed
	var movement : Vector3 = Vector3(flatMovement.x, 0, flatMovement.y)
	
	forces[0] = Vector3.DOWN * ((0.001/delta) if on_floor else gravity)
	if Input.is_action_just_pressed("ui_accept") and num_jumps > 0:
		velocity.y += jump_height
		num_jumps -= 1
		jumping = true
	for force in forces:
		velocity += force * delta
	var dMovement : Vector3 = (movement + velocity) * delta
	
	var num_collisions : int = 0
	for i in range(max_slides):
		var collision : KinematicCollision = move_and_collide(dMovement)
		if collision:
			num_collisions += 1
			on_floor = collision.normal.angle_to(Vector3.UP) <= max_floor_angle
			if fast_climbing and on_floor:
				dMovement = collision.remainder.slide(collision.normal).normalized() * dMovement.length()
			else:	
				dMovement = collision.remainder.slide(collision.normal)
			velocity = velocity.slide(collision.normal)
		else:
			break
	
	jumping = velocity.y > 0
	if num_collisions == 0:
		on_floor = false
	
	if on_floor:
		if !jumping: num_jumps = max_jumps
		velocity.x *= exp(log(floor_horiz_decay) * delta)
		velocity.z *= exp(log(floor_horiz_decay) * delta)
	else:
		velocity.x *= exp(log(air_horiz_decay) * delta)
		velocity.z *= exp(log(air_horiz_decay) * delta)
		velocity.y *= exp(log(air_vert_decay) * delta)

