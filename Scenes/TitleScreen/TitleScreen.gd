extends Control

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ESCAPE:
			get_tree().quit()

func _ready():
	for button in $Menu/CenterRow/Buttons.get_children():
		button.connect("pressed", self, "_on_button_pressed", [button.scene_to_load])

func _on_button_pressed(scene_to_load):
	get_tree().change_scene(scene_to_load)
