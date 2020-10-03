extends KinematicBody

var speed : float = 10
var velocity : Vector3
var margin : float = 1
var destination : Vector3
var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	get_new_destination()
	
func get_new_destination():
	destination = Vector3(rng.randf_range(-46, -16), rng.randf_range(1, 20), rng.randf_range(-46, 46))
	speed = rng.randf_range(10, 20)

func _physics_process(delta):
	var diff : Vector3 = destination - transform.origin
	if diff.length() <= margin:
		get_new_destination()
		diff = destination - transform.origin
	velocity = diff.normalized() * speed
	transform.origin += velocity * delta
