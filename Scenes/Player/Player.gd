extends KinematicBody

export var climb_speed : float = 6
export var jump_impulse : float = 10
export var max_jumps : int = 2
export var shooting_duration : float = 2
export var shooting_knockback : float = 18

export var run_speed : float = 15
export var gravity_force : float = 12
export var max_floor_angle : float = deg2rad(45)
export var rotation_speed : float = 10
export var snap_vector : Vector3 = Vector3.DOWN * 1

export var floor_horiz_decay : float = 0.05
export var air_horiz_decay : float = 0.8
export var air_vert_decay : float = 0.95

var is_climbing : bool = false
var is_jumping : bool = false
var num_jumps : int = max_jumps
var is_surfing : bool = false
var is_shooting : bool = false
var shooting_timer : float = -1
var is_gliding : bool = false

var old_rotation : float
var new_rotation : float
var rotation_weight : float = 1

var velocity : Vector3 = Vector3.ZERO
var forces : Array = []

func _ready():
	forces.append(Vector3.DOWN * gravity_force) #gravitational force

func _process(delta: float) -> void:
	#update shooting timer
	if shooting_timer != -1:
		shooting_timer += delta
		if shooting_timer > shooting_duration:
			is_shooting = false
			shooting_timer = -1
	
	#handle vertical rotation lerping
	if rotation_weight < 1:
		rotation_weight = min(1, rotation_weight + rotation_speed * delta)
		$MeshInstance.rotation.y = lerp_angle(old_rotation, new_rotation, rotation_weight)

func _input(event):
	if event.is_action_pressed("jump") and num_jumps > 0:
		velocity.y = jump_impulse
		num_jumps -= 1
		is_jumping = true
		$Jump.play()
	if event.is_action_pressed("shoot"):
		velocity += $Camera.transform.basis.z.normalized() * shooting_knockback
		is_shooting = true
		shooting_timer = 0
		$Shoot.play()
	if event.is_action_pressed("reset_velocity"):
		velocity = Vector3.ZERO

func _physics_process(delta):
	var arrows : Vector2 = Vector2.ZERO
	if Input.is_action_pressed("left"): arrows.x -= 1
	if Input.is_action_pressed("right"): arrows.x += 1
	if Input.is_action_pressed("up"): arrows.y -= 1
	if Input.is_action_pressed("down"): arrows.y += 1
	
	var flat_movement : Vector2 = arrows.normalized().rotated(-$Camera.ori.x + PI) * run_speed
	var movement : Vector3 = Vector3(flat_movement.x, 0, flat_movement.y)
	
	#take care of vertical rotation in movement direction
	if is_shooting or flat_movement.length() != 0:
		var rot : float = ($Camera.ori.x + PI) if is_shooting else -(flat_movement.angle() + PI/2)
		if rot != new_rotation:
			old_rotation = $MeshInstance.rotation.y
			new_rotation = rot
			rotation_weight = 0
	
	#take care of climbing movement
	if is_climbing and arrows.y == -1:
		velocity.y = 0
		movement.y += climb_speed * sign($Camera.ori.y)
	
	#apply the movement
	var prev_is_on_floor : bool = is_on_floor()
	var prev_is_surfing : bool = is_surfing
	if is_surfing:
		move_and_slide_with_snap(movement + velocity, snap_vector, Vector3.UP)
	else:
		move_and_slide(movement + velocity, Vector3.UP)
	if !prev_is_on_floor and is_on_floor():
		$Land.play()
	
	#slide existing velocity and check for ladder collisions
	is_climbing = false
	var collision : KinematicCollision
	for i in range(get_slide_count()):
		collision = get_slide_collision(i)
		velocity = velocity.slide(collision.normal)
		is_climbing = collision.collider.is_in_group("ladder") or is_climbing
		is_surfing = collision.collider.is_in_group("moving_platform") or is_surfing
	
	#stick to platform when landing
	if !prev_is_surfing and is_surfing:
		velocity = Vector3.ZERO
	
	#decide whether player is jumping and climbing
	if velocity.y < 0:
		is_jumping = false
	if velocity.y > 0:
		is_surfing = false
		velocity += get_floor_velocity()
	
	#reset available jumps, if necessary
	if is_climbing or (is_on_floor() and !is_jumping): 
		num_jumps = max_jumps
	
	#apply drag to current velocity
	if is_on_floor():
		velocity.x *= exp(log(floor_horiz_decay) * delta)
		velocity.z *= exp(log(floor_horiz_decay) * delta)
	else:
		velocity.x *= exp(log(air_horiz_decay) * delta)
		velocity.z *= exp(log(air_horiz_decay) * delta)
		velocity.y *= exp(log(air_vert_decay) * delta)
	
	#set forces
	forces[0] = Vector3.DOWN * ((0.001/delta) if (is_on_floor() or is_climbing) else gravity_force)
		
	#apply recorded forces to velocity
	for force in forces:
		velocity += force * delta
	
	print(velocity)
