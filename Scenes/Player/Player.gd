extends KinematicBody

export var max_collisions : int = 5

export var run_speed : float = 10
export var climb_speed : float = 6
export var jump_height : float = 8
export var max_jumps : int = 2
export var gravity : float = 15
export var rotationSpeed : float = 10
export var sprint_speed_scalar : float = 1.5

export var floor_horiz_decay : float = 0.05
export var air_horiz_decay : float = 0.5
export var air_vert_decay : float = 0.95

export var max_floor_angle : float = deg2rad(45)
export var fast_slopes : bool = false
export var shooting_duration : float = 2
export var shooting_knockback : float = 18

export var controlled : bool = true

var old_rotation : float
var new_rotation : float
var rotation_weight : float = 1

var velocity : Vector3 = Vector3.ZERO
var forces : Array = []

var on_floor : bool = false
var jumping : bool = false
var num_jumps : int = max_jumps
var climbing : bool = false
var shooting : bool = false
var shooting_timer : float = -1
var sprinting : bool = false
var sprint_direction : bool = false

func _ready() -> void:
	forces.append(Vector3.DOWN * gravity) #gravitational force
	if controlled:
		$Camera.current = true

func _process(delta: float) -> void:
	#update shooting timer
	if shooting_timer != -1:
		shooting_timer += delta
		if shooting_timer > shooting_duration:
			shooting = false
			shooting_timer = -1
	
	#handle vertical rotation lerping
	if rotation_weight < 1:
		rotation_weight = min(1, rotation_weight + rotationSpeed * delta)
		$MeshInstance.rotation.y = lerp_angle(old_rotation, new_rotation, rotation_weight)

func _input(event: InputEvent) -> void:
	#handle jump input and maintain number of available jumps
	if Input.is_action_just_pressed("jump") and num_jumps > 0:
		velocity.y = jump_height
		num_jumps -= 1
		jumping = true
		$Jump.play()
	
	#shooting handling
	if Input.is_action_just_pressed("shoot"): #is_action_just_pressed is brok
		velocity += $Camera.transform.basis.z.normalized() * shooting_knockback
		shooting = true
		shooting_timer = 0
		sprinting = false
		$Shoot.play()
	
	#sprint handling
	if event.is_action_pressed("sprint"):
		if sprinting:
			sprinting = false
		else:
			if sprint_direction:
				sprinting = true
				shooting = false
				shooting_timer = -1
	
	if event.is_action_pressed("reset_velocity"):
		velocity = Vector3.ZERO

func _physics_process(delta: float) -> void:
	#read movement keypress input
	var arrows : Vector2 = Vector2.ZERO
	if Input.is_action_pressed("left"): arrows.x -= 1
	if Input.is_action_pressed("right"): arrows.x += 1
	if Input.is_action_pressed("up"): arrows.y -= 1
	if Input.is_action_pressed("down"): arrows.y += 1
	
	#handle sprinting logic
	sprint_direction = arrows.y == -1
	if !sprint_direction: 
		sprinting = false
	
	#derive movement vectors from input
	var flatMovement : Vector2 = arrows.normalized().rotated(-$Camera.ori.x + PI) * (sprint_speed_scalar if sprinting else 1) * run_speed
	var movement : Vector3 = Vector3(flatMovement.x, 0, flatMovement.y)
	
	#take care of vertical rotation in movement direction
	if shooting or flatMovement.length() != 0:
		var rot : float = ($Camera.ori.x + PI) if shooting else -(flatMovement.angle() + PI/2)
		if rot != new_rotation:
			old_rotation = $MeshInstance.rotation.y
			new_rotation = rot
			rotation_weight = 0
	
	#set gravity force based on whether player is on floor
	#(minimal value always needed to maintain contact with floor)
	forces[0] = Vector3.DOWN * ((0.001/delta) if (on_floor or climbing) else gravity)
		
	#apply recorded forces to velocity
	for force in forces:
		velocity += force * delta
	
	#derive final movement vector based on movement, velocity and delta
	var d_movement : Vector3 = (movement + velocity) * delta
	
	#move and collide up to max of max_collisions this frame
	#slide movement and velocity vectors across planes of collision
	#maintain number of collisions and whether each collision indicates
	#player is on the floor
	var num_collisions : int = 0
	var prev_on_floor : bool = on_floor
	for i in range(max_collisions):
		var collision : KinematicCollision = move_and_collide(d_movement)
		if collision:
			num_collisions += 1
			on_floor = collision.normal.angle_to(Vector3.UP) <= max_floor_angle
			climbing = collision.collider.is_in_group("ladder")
			if fast_slopes and on_floor:
				d_movement = collision.remainder.slide(collision.normal).normalized() * d_movement.length()
			elif climbing:
				d_movement.x = collision.remainder.slide(collision.normal).x
				d_movement.z = collision.remainder.slide(collision.normal).z
				d_movement.y = max(0, -movement.normalized().dot(collision.normal)) * climb_speed * delta
				velocity.y = 0 #prevent accumulation due to gravity
			else:	
				d_movement = collision.remainder.slide(collision.normal)
			velocity = velocity.slide(collision.normal)
		else:
			break
	
	#check if player landed this frame
	if !prev_on_floor and on_floor:
		$Land.play()
	
	#decide whether player is jumping and/or on the floor
	jumping = velocity.y > 0
	if num_collisions == 0:
		on_floor = false
		climbing = false
	
	#reset available jumps, if necessary
	if climbing or (on_floor and !jumping): 
		num_jumps = max_jumps
	
	#apply appropriate velocity decay
	if on_floor:
		velocity.x *= exp(log(floor_horiz_decay) * delta)
		velocity.z *= exp(log(floor_horiz_decay) * delta)
	else:
		velocity.x *= exp(log(air_horiz_decay) * delta)
		velocity.z *= exp(log(air_horiz_decay) * delta)
		velocity.y *= exp(log(air_vert_decay) * delta)

