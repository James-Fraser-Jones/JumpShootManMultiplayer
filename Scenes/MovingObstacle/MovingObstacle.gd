extends KinematicBody

export var speed : float = 10
export var directions : Array = [Vector3.RIGHT, Vector3.FORWARD, Vector3.LEFT, Vector3.BACK, Vector3.UP, Vector3.DOWN]
export var switch : float = 2

var i : int = 0
var timer : float = 0
var velocity : Vector3 = directions[i] * speed

func _physics_process(delta):
	timer += delta
	if timer > switch:
		i = (i+1) % directions.size()
		timer = fmod(timer, switch)
	velocity = directions[i] * speed
	move_and_slide(velocity)
	
	var collision : KinematicCollision
	for i in range(get_slide_count()):
		collision = get_slide_collision(i)
		if collision.collider.is_in_group("player"):
			var player : KinematicBody = collision.collider
			player.offset += velocity


