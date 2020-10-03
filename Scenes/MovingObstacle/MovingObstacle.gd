extends KinematicBody

#export var directions : Array = [Vector3.RIGHT, Vector3.FORWARD, Vector3.LEFT, Vector3.BACK, Vector3.UP, Vector3.DOWN]
#export var switch : float = 2
#export var positions : Array = [Vector3(-26, 1.6, 42), Vector3(-26, 1.6, 9)]
var speed : float = 10

#var i : int = 0
#var timer : float = 0
var velocity : Vector3
var margin : float = 1
var destination : Vector3
var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	get_new_destination()
	
func get_new_destination():
	destination = Vector3(rng.randf_range(-46, -16), rng.randf_range(1, 20), rng.randf_range(-46, 46))
	#destination = Vector3(rng.randf_range(-46, -46), rng.randf_range(1, 20), rng.randf_range(-46, -46))
	speed = rng.randf_range(2, 20)

func _physics_process(delta):
	var diff : Vector3 = destination - transform.origin
	if diff.length() <= margin:
		get_new_destination()
		diff = destination - transform.origin
	velocity = diff.normalized() * speed
	transform.origin += velocity * delta
	
	#timer += delta
	#if timer > switch:
	#	i = (i+1) % directions.size()
	#	timer = fmod(timer, switch)
	#velocity = directions[i] * speed
