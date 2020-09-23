tool
extends Node

#https://medium.com/@Jacob_Bell/programmers-guide-to-gamma-correction-4c1d3a1724fb
#this script fixes gamma issues when importing Godot scenes

export var path : String
export var reverse : bool = false
export var fix : bool = false setget run_fix

func run_fix(v):
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if !dir.current_is_dir() and file_name.ends_with(".material"):
				var fullPath : String = "res://" + path + "/" + file_name
				var mat : SpatialMaterial = load(fullPath)
				var color : Color = mat.albedo_color
				color = gamma_correction(color, reverse)
				mat.albedo_color = color
				ResourceSaver.save(fullPath, mat)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")

func gamma_correction(color : Color, reverse : bool) -> Color:
	var p : float = 1/(2.2) if reverse else 2.2
	color.r = pow(color.r,p)
	color.g = pow(color.g,p)
	color.b = pow(color.b,p)
	return color
