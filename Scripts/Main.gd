extends Spatial

#UNITS:
#Distance: Meters
#Mass: Kilograms

#TODO:
#Clipping Camera
#	cast a ray from camera to player (or orbit point, I'm not sure)
#	if player is NOT visible, cast a ray from player to camera to find blocker nearest player
#	place camera ahead of that blocker by a given "radius"
#Increase player transparency as clipped camera gets closer to player
#Max velocity from directional movement
#	this can be done by looking at direction of existing velocity
#	finding component of the force to be added from directional movement in this direction
#	culling this component so that, when applied, it will not push velocity in that direction
#	beyond a given "max speed". This will still allow other forces to shoot the player
#	in any given direction beyond that max speed.
#Jumps gated by standing on ground of less than a specific angle
#Add health and death mechanics
#Add guns, bullet spawning, bullet collision and logic
#Add multiplayer

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ESCAPE:
			get_tree().quit()
		if event.pressed and event.scancode == KEY_R:
			get_tree().reload_current_scene()

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
