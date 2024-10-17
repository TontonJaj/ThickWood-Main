extends Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func convert_to_array_mesh(mesh_instance: MeshInstance3D) -> ArrayMesh:
	# Get the original mesh
	var original_mesh = mesh_instance.mesh
	
	# Check if the original mesh is already an ArrayMesh
	if original_mesh is ArrayMesh:
		return original_mesh
	
	# If it's not an ArrayMesh, we need to create one
	var array_mesh = ArrayMesh.new()
	
	# Get the surface count of the original mesh
	var surface_count = original_mesh.get_surface_count()
	
	# Iterate through each surface
	for surface_index in range(surface_count):
		# Get the array of the current surface
		var arrays = original_mesh.surface_get_arrays(surface_index)
		
		# Get the material of the current surface
		var material = original_mesh.surface_get_material(surface_index)
		
		# Add the surface to the new ArrayMesh
		array_mesh.add_surface_from_arrays(
			original_mesh.surface_get_primitive_type(surface_index),
			arrays
		)
		
		# Set the material for the new surface
		array_mesh.surface_set_material(surface_index, material)
	
	return array_mesh

func visualize_array_mesh(array_mesh: ArrayMesh, original_tree_mesh: MeshInstance3D):
	# Create a new MeshInstance3D to display the ArrayMesh
	var new_mesh_instance = MeshInstance3D.new()
	new_mesh_instance.mesh = array_mesh

	# Set a new material to make it distinct
	var new_material = StandardMaterial3D.new()
	new_material.albedo_color = Color(210.0/255.0, 180.0/255.0, 140.0/255.0, 0.9)
	new_material.flags_transparent = true
	new_mesh_instance.material_override = new_material

	# Add the new MeshInstance3D to the scene
	add_child(new_mesh_instance)

	# Match the transform of the original tree mesh
	new_mesh_instance.global_transform = original_tree_mesh.global_transform

	# Offset the position to make it appear deeper in the tree
	var offset = original_tree_mesh.global_transform.basis.z * -1  # Adjust this value as needed
	new_mesh_instance.global_translate(offset)

func visualize_vertices(vertices: Array, original_tree_mesh: MeshInstance3D):
	var vertex_mesh = ImmediateMesh.new()
	var vertex_instance = MeshInstance3D.new()
	vertex_instance.mesh = vertex_mesh

	var material = StandardMaterial3D.new()
	material.albedo_color = Color.BLACK
	material.flags_unshaded = true
	material.vertex_color_use_as_albedo = true
	vertex_instance.material_override = material

	vertex_mesh.clear_surfaces()
	vertex_mesh.surface_begin(Mesh.PRIMITIVE_POINTS, material)
	
	for vertex in vertices:
		vertex_mesh.surface_add_vertex(vertex)

	vertex_mesh.surface_end()

	add_child(vertex_instance)
	vertex_instance.global_transform = original_tree_mesh.global_transform

	# Make points larger for visibility
	vertex_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	vertex_instance.extra_cull_margin = 16384  # This makes the points always visible
	RenderingServer.global_shader_parameter_set("point_size", 10.0)  # Adjust size as needed
	
		# Offset the position to make it appear deeper in the tree
	var offset = original_tree_mesh.global_transform.basis.z * -1  # Adjust this value as needed
	vertex_instance.global_translate(offset)

func add_vertices_to_tree_mesh(treeDictionary) -> void:
	var original_tree_mesh = treeDictionary.collider.get_parent()
	var tree_arrayMesh = convert_to_array_mesh(original_tree_mesh)
	var surface_arrays = tree_arrayMesh.surface_get_arrays(0)
	var vertices = surface_arrays[Mesh.ARRAY_VERTEX]
	var indices = surface_arrays[Mesh.ARRAY_INDEX]

	# Find the closest existing vertices to the new points
	var closest_indices = find_closest_vertices(vertices, [treeDictionary.top, treeDictionary.bottom])

	# Add new vertices for the cut
	var new_vertex_start = vertices.size()
	vertices.append(treeDictionary.top)
	vertices.append(treeDictionary.depth)
	vertices.append(treeDictionary.bottom)

	# Create new faces
	# Top triangle
	indices.append(closest_indices[0])
	indices.append(new_vertex_start)  # top
	indices.append(new_vertex_start + 1)  # depth

	# Bottom triangle
	indices.append(closest_indices[1])
	indices.append(new_vertex_start + 1)  # depth
	indices.append(new_vertex_start + 2)  # bottom

	# Side triangles
	indices.append(closest_indices[0])
	indices.append(new_vertex_start + 1)  # depth
	indices.append(closest_indices[1])

	indices.append(closest_indices[0])
	indices.append(new_vertex_start + 2)  # bottom
	indices.append(new_vertex_start)  # top

	# Create a new ArrayMesh
	var new_array_mesh = ArrayMesh.new()
	var new_arrays = []
	new_arrays.resize(Mesh.ARRAY_MAX)
	new_arrays[Mesh.ARRAY_VERTEX] = vertices
	new_arrays[Mesh.ARRAY_INDEX] = indices

	# If the original mesh had normals, we should recalculate them
	if surface_arrays[Mesh.ARRAY_NORMAL]:
		new_arrays[Mesh.ARRAY_NORMAL] = recalculate_normals(vertices, indices)

	# Add the surface to the new ArrayMesh
	new_array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, new_arrays)

	# Copy materials from the original mesh
	for i in range(tree_arrayMesh.get_surface_count()):
		var material = tree_arrayMesh.surface_get_material(i)
		new_array_mesh.surface_set_material(i, material)

	# Visualize the new vertices
	var new_vertices = [treeDictionary.top, treeDictionary.depth, treeDictionary.bottom]
	visualize_vertices(new_vertices, original_tree_mesh)

	# Visualize the new ArrayMesh
	visualize_array_mesh(new_array_mesh, original_tree_mesh)

func find_closest_vertices(vertices: Array, target_points: Array) -> Array:
	var closest_indices = []
	for point in target_points:
		var closest_index = 0
		var closest_distance = INF
		for i in range(vertices.size()):
			var distance = vertices[i].distance_to(point)
			if distance < closest_distance:
				closest_distance = distance
				closest_index = i
		closest_indices.append(closest_index)
	return closest_indices

func recalculate_normals(vertices: PackedVector3Array, indices: PackedInt32Array) -> PackedVector3Array:
	var normals = PackedVector3Array()
	normals.resize(vertices.size())

	for i in range(0, indices.size(), 3):
		var a = vertices[indices[i]]
		var b = vertices[indices[i+1]]
		var c = vertices[indices[i+2]]
		var normal = (b - a).cross(c - a).normalized()

		normals[indices[i]] += normal
		normals[indices[i+1]] += normal
		normals[indices[i+2]] += normal

	for i in range(normals.size()):
		normals[i] = normals[i].normalized()

	return normals
