extends Area3D

@onready var WoodTransformer = $"."
# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	#connect signals
	#connect("body_entered", self, "_on_body_entered")
	#connect("body_exited", self, "_on_body_exited")


func _on_body_entered(body: Node3D):
	#Check if the body is a meshInstance3D
	if body is RigidBody3D:
		var mesh_instance = find_mesh_instance(body)
		if mesh_instance:
			var volume = calculate_volume(mesh_instance)
			print("Volume of the mesh: ", volume)
		

func find_mesh_instance(rigid_body: RigidBody3D) -> MeshInstance3D:
	for child in rigid_body.get_children():
		if child is MeshInstance3D:
			return child  # Return the first MeshInstance3D found
	return null  # Return null if no MeshInstance3D is found


func _on_body_exited(body: Node3D):
	# Logic for when a body exits the area
	print("Body exited: ", body.name)


func calculate_volume(mesh_instance: MeshInstance3D) -> float:
	var volume = 0.0
	var mesh = mesh_instance.get_mesh()

	if mesh:
		#loop through surfaces to calculate volume
		for i in range(mesh.get_surface_count()):
			var arrays = mesh.surface_get_arrays(i)
			var vertices = arrays[ArrayMesh.ARRAY_VERTEX]
			var indices = arrays[ArrayMesh.ARRAY_INDEX]
			
		# Loop through triangles to calculate volume
			for j in range(0, indices.size(), 3):
				if j + 2 < indices.size():
					var v1 = vertices[indices[j]]
					var v2 = vertices[indices[j + 1]]
					var v3 = vertices[indices[j + 2]]
					volume += calculate_triangle_volume(v1, v2, v3)
			# Assuming the mesh is a surface tool generated mesh
							
	return volume
		
		
func calculate_triangle_volume(v1: Vector3, v2: Vector3, v3: Vector3) -> float:
	#calculate volume of a tetrahedron with one vertex at the origin
	return abs(v1.dot(v2.cross(v3))) / 6.0
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
