extends KinematicBody

export var acceleration : float = 50
export var max_speed : float = 30
export var move : bool = true

var velocity : Vector3
var destination : Vector3
var diff_length : float
var rng = RandomNumberGenerator.new()
var decelerate : bool

func _ready():
	rng.randomize()
	get_new_destination()
	
func _physics_process(delta):
	var diff : Vector3 = destination - transform.origin
	if diff.length() > diff_length:
		get_new_destination()
		diff = destination - transform.origin
		velocity = Vector3()
		decelerate = false
	decelerate = decelerate or decelerate(diff.length())
	if decelerate:
		velocity -= diff.normalized() * acceleration * delta
	elif velocity.length() < max_speed:
		velocity += diff.normalized() * acceleration * delta
	if !move: velocity = Vector3()
	transform.origin += velocity * delta
	diff_length = diff.length()
	
func get_new_destination():
	destination = Vector3(rng.randf_range(-46, -16), rng.randf_range(1, 25), rng.randf_range(-46, 46))

func decelerate(distance_remaining : float) -> bool:
	return (distance_remaining <= (pow(velocity.length(), 2)/(2*acceleration)))
