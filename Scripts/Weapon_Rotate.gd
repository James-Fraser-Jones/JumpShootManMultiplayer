extends Spatial

func _process(delta: float) -> void:
	rotate_y(PI/1.5 * delta)
