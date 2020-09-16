extends Spatial

#NOTE: FROM HERE ON THE PROJECT WILL BE USING GODOT'S 3D UNITS TO BE METERS.

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ESCAPE:
			get_tree().quit()
		if event.pressed and event.scancode == KEY_R:
			get_tree().reload_current_scene()

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
