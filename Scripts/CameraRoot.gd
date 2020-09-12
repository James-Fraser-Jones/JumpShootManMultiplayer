extends Spatial

export var sensitivityX = 10
export var sensitivityY = 8
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate(Vector3.UP, -event.relative.x/1000 * sensitivityX)
		rotate_object_local(Vector3.RIGHT, -event.relative.y/1000 * sensitivityY)
