extends KinematicBody

export var move_speed : float = 15
export var move_decel : float = 5
export var gravity : float = 12
export var jump_force : float = 10
export var climb_speed : float = 6

export var floor_horiz_decay : float = 0.05
export var air_horiz_decay : float = 0.8
export var air_vert_decay : float = 0.95

export var shooting_knockback : float = 18

var climbing : bool = false
var velocity : Vector3 = Vector3.ZERO
#var pushed : bool = false
var offset : Vector3 = Vector3.ZERO

func _input(event):
	if Input.is_action_just_pressed("shoot"): #is_action_just_pressed is brok
		velocity += $Camera.transform.basis.z.normalized() * shooting_knockback
	if Input.is_action_just_pressed("jump"):
		velocity.y = jump_force

func _physics_process(delta):
	var arrows : Vector2 = Vector2.ZERO
	if Input.is_action_pressed("left"): arrows.x -= 1
	if Input.is_action_pressed("right"): arrows.x += 1
	if Input.is_action_pressed("up"): arrows.y -= 1
	if Input.is_action_pressed("down"): arrows.y += 1
	
	var flatMovement : Vector2 = arrows.normalized().rotated(-$Camera.ori.x + PI) * move_speed
	var movement : Vector3 = Vector3(flatMovement.x, 0, flatMovement.y)
	
	if climbing and arrows.y == -1:
		velocity.y = 0
		movement.y += climb_speed * sign($Camera.ori.y)
		
	move_and_slide(movement + velocity + offset, Vector3.UP, true)
	
	#slide existing velocity and check for ladder collisions
	climbing = false
	#pushed = false
	var collision : KinematicCollision
	for i in range(get_slide_count()):
		collision = get_slide_collision(i)
		velocity = velocity.slide(collision.normal)
		climbing = collision.collider.is_in_group("ladder") or climbing
		#pushed = collision.collider.is_in_group("moving_platform") or pushed
	
	#apply drag
	if is_on_floor():
		velocity.x *= exp(log(floor_horiz_decay) * delta)
		velocity.z *= exp(log(floor_horiz_decay) * delta)
	else:
		velocity.x *= exp(log(air_horiz_decay) * delta)
		velocity.z *= exp(log(air_horiz_decay) * delta)
		velocity.y *= exp(log(air_vert_decay) * delta)
	
	#apply gravity
	if is_on_floor():
		velocity.y -= 0.001
	else:
		velocity.y -= gravity * delta
		
	#reset offset
	offset = Vector3.ZERO
	
