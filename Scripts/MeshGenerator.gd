tool
extends Node

export var path : String
export var file_name : String
export var size : Vector3
export (float, 0, 1) var threshold : float = 0.2
export (NodePath) var mesh_instance_path
export var generate : bool = false setget run_generate

var st : SurfaceTool
var noise : OpenSimplexNoise

func run_generate(k):
	if path != "" and file_name != "":
		var full_path : String = "res://" + path + "/" + file_name + ".tres"
		
		noise = OpenSimplexNoise.new()
		noise.seed = randi()
		#noise.octaves = 4
		#noise.period = 20.0
		#noise.persistence = 0.8
		
		st = SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		add_cubes(Vector3.ZERO, Vector3(1,1,1), size)
		st.generate_normals()
		st.index()
		
		var mesh = st.commit()
		var dir = Directory.new()
		dir.remove(full_path)
		ResourceSaver.save(full_path, mesh, 32)
		
		if !mesh_instance_path.is_empty():
			var mesh_instance : MeshInstance = get_node(mesh_instance_path)
			mesh_instance.mesh = mesh
		
		file_name = ""

func add_triangle(a,b,c):
	st.add_vertex(a)
	st.add_vertex(b)
	st.add_vertex(c)

func add_square(a,b,c,d):
	add_triangle(a,b,c)
	add_triangle(b,d,c)
	
func add_cube(a,b,c,d,e,f,g,h):
	add_square(a,b,c,d)
	add_square(f,e,h,g)
	add_square(b,a,f,e)
	add_square(c,d,g,h)
	add_square(a,c,e,g)
	add_square(d,b,h,f)

func add_cube_safe(origin: Vector3, scale: Vector3):
	var a = origin
	var b = a + Vector3.RIGHT * scale.x
	var c = a + Vector3.FORWARD * scale.z
	var d = b + Vector3.FORWARD * scale.z
	var e = a + Vector3.UP * scale.y
	var f = b + Vector3.UP * scale.y
	var g = c + Vector3.UP * scale.y
	var h = d + Vector3.UP * scale.y
	add_cube(a,b,c,d,e,f,g,h)

func add_cubes(origin: Vector3, scale: Vector3, size: Vector3):
	for x in range(size.x):
		for y in range(size.y):
			for z in range(size.z):
				var this_origin : Vector3 = origin
				this_origin += Vector3(x,y,z) * scale
				var val : float = noise.get_noise_3d(x,y,z)
				if val <= threshold and val >= -threshold:
					add_cube_safe(this_origin, scale)
				else: print(val)
