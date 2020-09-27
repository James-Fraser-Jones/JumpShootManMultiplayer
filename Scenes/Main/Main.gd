extends Spatial

#UNITS:
#Distance: Meters

#DONE:
#Add camera clipping
#Add camera orientation smoothing
#Add camera yOffset scaling
#Add player distance fade
#Add camera radius smoothing
#Add camera offset smoothing
#Max velocity from directional movement

#TODO:
#Have jumps gated by standing on ground of less than a specific angle
#Add HUD health and death mechanics
#Add guns, bullet spawning, bullet collision and logic
#Add multiplayer
#Add sounds
#Add splash screen

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ESCAPE:
			get_tree().quit()
		if event.pressed and event.scancode == KEY_R:
			get_tree().reload_current_scene()

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
