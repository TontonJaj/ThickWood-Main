extends Node

#This is the main function being called by the player's axe colliding with a tree
func handleChop(chopDict: Dictionary) -> void:
	#Can only dynamically modify arrayMeshes in GDScript
	#Right now I'm deleting (QUEUE_FREE) but I should keep it and refresh its' mesh
	var arrayMeshAndTransform = get_array_mesh_and_transform(chopDict.collider) #this is queue_freeing() don't forget to update instead in future
	if arrayMeshAndTransform.array_mesh == null or arrayMeshAndTransform.transform == null:
		return
	var basis = get_median_basis(chopDict.basisArray)
	var medianPoint = getMedianPoint(chopDict.top, chopDict.depth, chopDict.bottom)
	var treeArrayMesh = arrayMeshAndTransform.array_mesh
	var originalTreeTransform = arrayMeshAndTransform.transform
	
	
	#treeArrayMesh = addVerticesFromCollisions(originalTreeTransform, treeArrayMesh, chopDict)
	var chop_box_boundary = create_chop_box_boundary(medianPoint, basis)
	var projected_points = project_points_to_mesh(chop_box_boundary, treeArrayMesh, originalTreeTransform)
	visualize_chop_box_boundary(projected_points)
	print("Original vertex count: ", get_vertex_count(treeArrayMesh))
	treeArrayMesh = apply_surface_edges_to_mesh(
		treeArrayMesh,
		projected_points,
		originalTreeTransform
	)
	print("New vertex count: ", get_vertex_count(treeArrayMesh))
	
	visualize_direction_vector(medianPoint, basis.x)
	visualize_direction_vector(medianPoint, basis.y)
	visualize_direction_vector(medianPoint, basis.z)
	visualize_collision_point(chopDict.top, Color.WEB_PURPLE)
	visualize_collision_point(chopDict.depth, Color.PALE_VIOLET_RED)
	visualize_collision_point(chopDict.bottom, Color.LIGHT_PINK)
	add_skeleton_to_scene(originalTreeTransform, treeArrayMesh)
	add_transparent_to_scene(originalTreeTransform, treeArrayMesh)

func create_chop_box_boundary(medianPointIn, basisIn) -> Dictionary:
	var medianPoint = medianPointIn
	var basis = basisIn
	#actually get these referenced in the future!
	var _playerStrength = 1
	var _axeEfficiency = 1
	var axeBladeLength = 0.065
	var axeBladeWidth = 0.035
	#actually get these referenced in the future!
	
	var chop_box_boundary_dictionnary = {
	"topLeftPoint": null,
	"topMiddlePoint": null,
	"topRightPoint": null,
	"middleLeftPoint": null,
	"middleMiddlePoint": null,
	"middleRightPoint": null,
	"bottomLeftPoint": null,
	"bottomMiddlePoint": null,
	"bottomRightPoint": null
	}
	var cbbd = chop_box_boundary_dictionnary
	
	cbbd.middleMiddlePoint = medianPoint
	cbbd.middleLeftPoint = medianPoint + (-basis.y*axeBladeLength)
	cbbd.middleRightPoint = medianPoint + (basis.y*axeBladeLength)
	cbbd.topLeftPoint = cbbd.middleLeftPoint + (-basis.x*axeBladeWidth)
	cbbd.topMiddlePoint = cbbd.middleMiddlePoint + (-basis.x*axeBladeWidth)
	cbbd.topRightPoint = cbbd.middleRightPoint + (-basis.x*axeBladeWidth)
	cbbd.bottomLeftPoint = cbbd.middleLeftPoint + (basis.x*axeBladeWidth)
	cbbd.bottomMiddlePoint = cbbd.middleMiddlePoint + (basis.x*axeBladeWidth)
	cbbd.bottomRightPoint = cbbd.middleRightPoint + (basis.x*axeBladeWidth)
	
	return cbbd

# Helper function to get vertex count safely
func get_vertex_count(mesh: ArrayMesh) -> int:
	if mesh.get_surface_count() > 0:
		var arrays = mesh.surface_get_arrays(0)
		if arrays and Mesh.ARRAY_VERTEX < arrays.size():
			return arrays[Mesh.ARRAY_VERTEX].size()
	return 0

const EPSILON = 0.0000001

func apply_surface_edges_to_mesh(mesh: ArrayMesh, projected_points: Dictionary, originalTreeTransform: Transform3D) -> ArrayMesh:
	var mesh_data = mesh.surface_get_arrays(0)
	var vertices = mesh_data[Mesh.ARRAY_VERTEX]
	var indices = mesh_data[Mesh.ARRAY_INDEX]
	var normals = mesh_data[Mesh.ARRAY_NORMAL] if mesh_data[Mesh.ARRAY_NORMAL] else []
	var uvs = mesh_data[Mesh.ARRAY_TEX_UV] if mesh_data[Mesh.ARRAY_TEX_UV] else []

	var new_vertices = []
	var new_edges = []

	# Transform projected points to local space and add to new_vertices
	for point in projected_points.values():
		new_vertices.append(originalTreeTransform.affine_inverse() * point)

	# Generate edges between projected points
	var points_array = projected_points.values()
	for i in range(points_array.size()):
		for j in range(i + 1, points_array.size()):
			generate_edge(new_vertices, new_edges, originalTreeTransform, points_array[i], points_array[j], vertices, indices)

	# Add new vertices and edges to the mesh
	var vertex_offset = vertices.size()
	vertices.append_array(new_vertices)

	for edge in new_edges:
		add_edge_to_mesh(vertices, indices, normals, uvs, vertex_offset + edge[0], vertex_offset + edge[1])

	# Ensure all arrays are the correct size
	while normals.size() < vertices.size():
		normals.append(Vector3.UP)
	while uvs.size() < vertices.size():
		uvs.append(Vector2.ZERO)

	# Create and return the new mesh
	return create_new_mesh(vertices, indices, normals, uvs, mesh)

func generate_edge(new_vertices, new_edges, transform, start, end, vertices, indices):
	var local_start = transform.affine_inverse() * start
	var local_end = transform.affine_inverse() * end
	var intersections = []

	# Check for intersections with mesh triangles
	for k in range(0, indices.size(), 3):
		var intersection = ray_triangle_intersection(local_start, local_end - local_start,
			vertices[indices[k]], vertices[indices[k+1]], vertices[indices[k+2]])
		if intersection:
			var idx = point_exists(intersection, new_vertices)
			if idx == -1:
				new_vertices.append(intersection)
				idx = new_vertices.size() - 1
			intersections.append(idx)

	# Sort intersections by distance from start
	intersections.sort_custom(func(a, b): return new_vertices[a].distance_to(local_start) < new_vertices[b].distance_to(local_start))

	# Create edges using intersections
	var last_idx = point_exists(local_start, new_vertices)
	for intersection in intersections:
		if last_idx != intersection:
			new_edges.append([last_idx, intersection])
			last_idx = intersection
	
	var end_idx = point_exists(local_end, new_vertices)
	if last_idx != end_idx:
		new_edges.append([last_idx, end_idx])

func add_edge_to_mesh(vertices, indices, normals, uvs, v1, v2):
	var v3 = vertices.size()
	
	# Create a new vertex slightly offset from the edge midpoint
	var midpoint = (vertices[v1] + vertices[v2]) / 2
	var normal = (vertices[v2] - vertices[v1]).cross(Vector3.UP).normalized()
	vertices.append(midpoint + normal * 0.01)
	
	# Add two triangles for the edge
	indices.append_array([v1, v2, v3, v2, v1, v3])

	# Add corresponding normals and UVs for the new vertex
	if normals:
		normals.append(normal)
	if uvs:
		uvs.append(Vector2((uvs[v1].x + uvs[v2].x) / 2, (uvs[v1].y + uvs[v2].y) / 2))

func create_new_mesh(vertices, indices, normals, uvs, original_mesh):
	var new_mesh = ArrayMesh.new()
	var new_mesh_data = []
	new_mesh_data.resize(Mesh.ARRAY_MAX)
	
	# Ensure correct array types
	new_mesh_data[Mesh.ARRAY_VERTEX] = PackedVector3Array(vertices)
	new_mesh_data[Mesh.ARRAY_INDEX] = PackedInt32Array(indices)
	new_mesh_data[Mesh.ARRAY_NORMAL] = PackedVector3Array(normals)
	new_mesh_data[Mesh.ARRAY_TEX_UV] = PackedVector2Array(uvs)

	# Check if we have valid data before adding the surface
	if not new_mesh_data[Mesh.ARRAY_VERTEX].is_empty() and not new_mesh_data[Mesh.ARRAY_INDEX].is_empty():
		new_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, new_mesh_data)

		# Copy materials from the original mesh
		for i in range(original_mesh.get_surface_count()):
			if i < new_mesh.get_surface_count():  # Ensure we don't exceed the new surface count
				var material = original_mesh.surface_get_material(i)
				if material:
					new_mesh.surface_set_material(i, material)
	else:
		print("Warning: Not enough data to create a new mesh surface")

	return new_mesh

func point_exists(point: Vector3, vertices) -> int:
	for i in range(vertices.size()):
		if vertices[i].distance_to(point) < 0.001:
			return i
	return -1

func ray_triangle_intersection(ray_origin: Vector3, ray_direction: Vector3, v1: Vector3, v2: Vector3, v3: Vector3) -> Vector3:
	var edge1 = v2 - v1
	var edge2 = v3 - v1
	var h = ray_direction.cross(edge2)
	var a = edge1.dot(h)

	if a > -EPSILON and a < EPSILON:
		return Vector3.ZERO  # Ray is parallel to the triangle

	var f = 1.0 / a
	var s = ray_origin - v1
	var u = f * s.dot(h)

	if u < 0.0 or u > 1.0:
		return Vector3.ZERO

	var q = s.cross(edge1)
	var v = f * ray_direction.dot(q)

	if v < 0.0 or u + v > 1.0:
		return Vector3.ZERO

	var t = f * edge2.dot(q)

	if t > EPSILON:
		return ray_origin + ray_direction * t
	else:
		return Vector3.ZERO

func project_points_to_mesh(points: Dictionary, mesh: ArrayMesh, treeTransform) -> Dictionary:
	var projected_points = {}
	var mesh_data = mesh.surface_get_arrays(0)
	var vertices = mesh_data[Mesh.ARRAY_VERTEX]
	var indices = mesh_data[Mesh.ARRAY_INDEX]
	
	# Get the inverse transform of the tree
	var inverse_transform = treeTransform.affine_inverse()

	for point_name in points:
		var point = points[point_name]
		if point is Vector3:
			# Transform the point to local space
			var local_point = inverse_transform * point
			
			var closest_point = Vector3.ZERO
			var min_distance = INF

			# Iterate through all triangles in the mesh
			for i in range(0, indices.size(), 3):
				var v1 = vertices[indices[i]]
				var v2 = vertices[indices[i+1]]
				var v3 = vertices[indices[i+2]]

				# Calculate the closest point on this triangle
				var triangle_point = closest_point_on_triangle(local_point, v1, v2, v3)
				var distance = local_point.distance_to(triangle_point)

				# Update if this is the closest point so far
				if distance < min_distance:
					min_distance = distance
					closest_point = triangle_point

			# Transform the closest point back to global space
			projected_points[point_name] = treeTransform * closest_point
		else:
			print("Warning: ", point_name, " is not a Vector3 or is null.")

	return projected_points

func closest_point_on_triangle(p: Vector3, a: Vector3, b: Vector3, c: Vector3) -> Vector3:
	var ab = b - a
	var ac = c - a
	var ap = p - a

	var d1 = ab.dot(ap)
	var d2 = ac.dot(ap)

	# Barycentric coordinates
	if d1 <= 0 and d2 <= 0:
		return a

	var bp = p - b
	var d3 = ab.dot(bp)
	var d4 = ac.dot(bp)

	if d3 >= 0 and d4 <= d3:
		return b

	var vc = d1 * d4 - d3 * d2
	if vc <= 0 and d1 >= 0 and d3 <= 0:
		var vv = d1 / (d1 - d3)
		return a + vv * ab

	var cp = p - c
	var d5 = ab.dot(cp)
	var d6 = ac.dot(cp)

	if d6 >= 0 and d5 <= d6:
		return c

	var vb = d5 * d2 - d1 * d6
	if vb <= 0 and d2 >= 0 and d6 <= 0:
		var www = d2 / (d2 - d6)
		return a + www * ac

	var va = d3 * d6 - d5 * d4
	if va <= 0 and (d4 - d3) >= 0 and (d5 - d6) >= 0:
		var ww = (d4 - d3) / ((d4 - d3) + (d5 - d6))
		return b + ww * (c - b)

	var denom = 1.0 / (va + vb + vc)
	var v = vb * denom
	var w = vc * denom
	return a + ab * v + ac * w

func visualize_chop_box_boundary(dictionary: Dictionary, point_color: Color = Color.CHOCOLATE, point_size: float = 0.01):
	for point_name in dictionary:
		var point_position = dictionary[point_name]
		if point_position is Vector3:
			var mesh_instance = MeshInstance3D.new()
			var sphere_mesh = SphereMesh.new()
			sphere_mesh.radius = point_size
			sphere_mesh.height = point_size * 2
			mesh_instance.mesh = sphere_mesh
			
			var material = StandardMaterial3D.new()
			material.albedo_color = point_color
			mesh_instance.set_surface_override_material(0, material)
			
			mesh_instance.position = point_position
			mesh_instance.name = point_name
			
			add_child(mesh_instance)
		else:
			print("Warning: ", point_name, " is not a Vector3 or is null.")

#will be deprecated soon
func addVerticesFromCollisions(originalTreeTransform, treeArrayMesh, chopDict):
	# Get both vertices and indices from the first surface
	var arrays = treeArrayMesh.surface_get_arrays(0)
	var vertices = arrays[Mesh.ARRAY_VERTEX]
	var indices = arrays[Mesh.ARRAY_INDEX]
	
	print("Vertices before adding: ", vertices.size())
	
	# Store the current vertex count before adding new ones
	var baseIndex = vertices.size()
	
	# Add new vertices to the array
	var localTop = originalTreeTransform.affine_inverse() * chopDict.top
	var localDepth = originalTreeTransform.affine_inverse() * chopDict.depth
	var localBottom = originalTreeTransform.affine_inverse() * chopDict.bottom
	
	vertices.append(localTop)
	vertices.append(localDepth)
	vertices.append(localBottom)
	
	# Add indices for the new triangle
	indices.append(baseIndex)      # localTop
	indices.append(baseIndex + 1)  # localDepth
	indices.append(baseIndex + 2)  # localBottom
	
	# Create a new surface with the updated vertices and indices
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	# First, add all vertices
	for i in range(vertices.size()):
		st.add_vertex(vertices[i])
	
	# Then add all indices to define the triangles
	for i in range(0, indices.size(), 3):
		st.add_index(indices[i])
		st.add_index(indices[i + 1])
		st.add_index(indices[i + 2])
	
	# Commit the changes to a new mesh
	var newMesh = st.commit()
	
	# Clear the original mesh and add the new surface
	treeArrayMesh.clear_surfaces()
	treeArrayMesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, newMesh.surface_get_arrays(0))
	
	print("Vertices after adding: ", vertices.size())
	return treeArrayMesh
	
func add_transparent_to_scene(originalTreeTransform, treeArrayMesh):
	# Create the transparent tree mesh
	var tree_instance = MeshInstance3D.new()
	var tree_material = StandardMaterial3D.new()

	# Set up the tree material
	tree_material.albedo_color = Color(0.9, 0.8, 0.7, 0.35)  # Light tan color with 50% opacity
	tree_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	tree_material.cull_mode = BaseMaterial3D.CULL_DISABLED  # Show both sides of the faces

	# Assign the mesh and material
	tree_instance.mesh = treeArrayMesh
	tree_instance.material_override = tree_material

	# Add the tree mesh instance to the scene
	add_child(tree_instance)

	# Set the transform for the tree
	tree_instance.global_transform = originalTreeTransform
	
func add_skeleton_to_scene(originalTreeTransform, treeArrayMesh):
	var new_mesh_instance = MeshInstance3D.new()
	var immediate_mesh = ImmediateMesh.new()
	var material = ORMMaterial3D.new()

	# Set up the material
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color.DARK_GOLDENROD
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_ALWAYS
	material.render_priority = 1  # Ensure it renders after the transparent tree

	# Create the immediate mesh
	new_mesh_instance.mesh = immediate_mesh
	new_mesh_instance.material_override = material

	# Add the mesh instance to the scene
	add_child(new_mesh_instance)

	# Set the transform
	new_mesh_instance.global_transform = originalTreeTransform

	# Draw the vertices and edges
	immediate_mesh.clear_surfaces()
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES)

	for i in range(treeArrayMesh.get_surface_count()):
		var arrays = treeArrayMesh.surface_get_arrays(i)
		var vertices = arrays[Mesh.ARRAY_VERTEX]
		var indices = arrays[Mesh.ARRAY_INDEX]
		
		for j in range(0, indices.size(), 3):
			var v1 = vertices[indices[j]]
			var v2 = vertices[indices[j+1]]
			var v3 = vertices[indices[j+2]]
			
			immediate_mesh.surface_add_vertex(v1)
			immediate_mesh.surface_add_vertex(v2)
			
			immediate_mesh.surface_add_vertex(v2)
			immediate_mesh.surface_add_vertex(v3)
			
			immediate_mesh.surface_add_vertex(v3)
			immediate_mesh.surface_add_vertex(v1)

	immediate_mesh.surface_end()
	
func get_array_mesh_and_transform(collider) -> Dictionary:
	var result = {
		"array_mesh": null,
		"transform": null
	}

	if collider is ArrayMesh:
		result.array_mesh = collider
		result.transform = collider.global_transform
	elif collider is MeshInstance3D:
		result.transform = collider.global_transform
		result.array_mesh = convert_instance_to_array_mesh(collider)
		collider.queue_free()
	else:
		var parent_mesh_instance = find_meshinstance3d_parent(collider)
		if parent_mesh_instance:
			result.transform = parent_mesh_instance.global_transform
			result.array_mesh = convert_instance_to_array_mesh(parent_mesh_instance)
			parent_mesh_instance.queue_free()
			
	if not (result.array_mesh is ArrayMesh):
		print('handleChop failing: Invalid ArrayMesh')

	if not (result.transform is Transform3D):
		print('handleChop failing: Invalid Transform')

	return result
	
func convert_instance_to_array_mesh(mesh_instance: MeshInstance3D) -> ArrayMesh:
	if not mesh_instance or not mesh_instance.mesh:
		return null
		
	var original_mesh = mesh_instance.mesh
	var array_mesh = ArrayMesh.new()
	
	for surface_idx in range(original_mesh.get_surface_count()):
		# Get the arrays and material from the original mesh
		var arrays = original_mesh.surface_get_arrays(surface_idx)
		var material = mesh_instance.get_surface_override_material(surface_idx)
		if material == null:
			material = original_mesh.surface_get_material(surface_idx)
			
		# Add the surface with the same format as the original
		array_mesh.add_surface_from_arrays(
			original_mesh.surface_get_primitive_type(surface_idx),
			arrays
		)
		
		# Apply the material to the new surface
		if material:
			array_mesh.surface_set_material(surface_idx, material)
	
	return array_mesh

func find_meshinstance3d_parent(node: Node) -> Node:
	var current_node = node.get_parent()
	while current_node:
		# Stop searching if we reach the "Trees" node
		if current_node.name == "Trees":
			return null
		# Check if the current node is of the target type
		if current_node is MeshInstance3D:
			return current_node
		current_node = current_node.get_parent()
	return null

func visualize_collision_point(collisionPos: Vector3, color: Color) -> void:
	if not is_inside_tree():
		print("Warning: Attempting to visualize collision point while not in scene tree.")
		return

	var sphere = CSGSphere3D.new()
	sphere.name = "Node_" + str(Time.get_ticks_msec())
	sphere.radius = 0.015

	# Create a new material
	var material = StandardMaterial3D.new()
	material.albedo_color = color
	
	# Assign the material to the sphere
	sphere.material = material

	# Add the sphere to the scene first
	get_tree().current_scene.add_child(sphere)

	# Then set its position
	sphere.global_transform.origin = collisionPos
	
	# Create a Timer node
	var timer = Timer.new()
	timer.set_wait_time(5.0)  # Set the timer for 6 seconds
	timer.set_one_shot(true)  # Make it a one-shot timer
	timer.connect("timeout", Callable(self, "_on_visualization_timer_timeout").bind(sphere))
	
	# Add the timer to the sphere
	sphere.add_child(timer)
	
	# Start the timer
	timer.start()
func _on_visualization_timer_timeout(sphere: CSGSphere3D) -> void:
	if is_instance_valid(sphere):
		sphere.queue_free()

func getMedianPoint(point1: Vector3, point2: Vector3, point3: Vector3):
	var vectorToReturn = Vector3(0, 0, 0)
	var xSum = point1.x + point2.x + point3.x
	var ySum = point1.y + point2.y + point3.y
	var zSum = point1.z + point2.z + point3.z
	
	vectorToReturn = Vector3(xSum/3, ySum/3, zSum/3)
	return vectorToReturn
	
func get_median_basis(basis_array):
	# Initialize empty vectors for summing X, Y, and Z
	var sum_x = Vector3(0, 0, 0)
	var sum_y = Vector3(0, 0, 0)
	var sum_z = Vector3(0, 0, 0)
	
	# Iterate through all the basis matrices and sum their X, Y, and Z vectors
	for basis in basis_array:
		sum_x += basis.x
		sum_y += basis.y
		sum_z += basis.z
	
	# Calculate the average by dividing by the number of basis matrices
	var count = basis_array.size()
	var avg_x = sum_x / count
	var avg_y = sum_y / count
	var avg_z = sum_z / count
	
	# Create a new Basis with the averaged and normalized vectors
	var median_basis = Basis(avg_x, avg_y, avg_z)
	
	return median_basis

func visualize_direction_vector(position: Vector3, direction: Vector3) -> void:
	const ARROW_LENGTH = 0.15  # Length of the visualization arrow
	const ARROW_COLOR = Color.MEDIUM_VIOLET_RED
	const LINE_THICKNESS = 0.005  # Thickness of the lines
	const ARROW_HEAD_SCALE = 0.1  # Arrow head size relative to length
	
	# Create a parent node for all meshes
	var arrow_parent = Node3D.new()
	add_child(arrow_parent)
	
	# Normalize the direction vector
	var normalized_dir = direction.normalized()
	
	# Calculate start and end points
	var start_point = position
	var end_point = position + normalized_dir * ARROW_LENGTH
	
	# Create the main line as a box
	var line = BoxMesh.new()
	var line_length = ARROW_LENGTH
	line.size = Vector3(LINE_THICKNESS, LINE_THICKNESS, line_length)
	
	var line_instance = MeshInstance3D.new()
	line_instance.mesh = line
	arrow_parent.add_child(line_instance)
	
	# Create material for all parts
	var material = StandardMaterial3D.new()
	material.shading_mode = StandardMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = ARROW_COLOR
	
	line_instance.material_override = material
	
	# Position the main line
	line_instance.position = start_point + normalized_dir * (line_length * 0.5)
	
	# Calculate basis for rotation
	var basis: Basis
	if abs(normalized_dir.dot(Vector3.UP)) > 0.99:
		# Handle near-vertical cases
		if normalized_dir.dot(Vector3.UP) > 0:
			basis = Basis(Vector3.FORWARD, Vector3.LEFT, Vector3.UP)
		else:
			basis = Basis(Vector3.FORWARD, Vector3.RIGHT, Vector3.DOWN)
	else:
		# For all other cases
		var rright = Vector3.UP.cross(normalized_dir).normalized()
		var uup = normalized_dir.cross(rright).normalized()
		basis = Basis(rright, uup, normalized_dir)
	
	line_instance.transform.basis = basis
	
	# Create arrow head
	var arrow_size = ARROW_LENGTH * ARROW_HEAD_SCALE
	
	# Calculate perpendicular vectors for arrow head
	var right = basis.x
	var up = basis.y
	
	# Create four arrow head lines with adjusted angles
	var arrow_angle = PI * 0.25  # 45 degrees for arrow head
	var arrow_directions = [
		(normalized_dir * -cos(arrow_angle) + right * sin(arrow_angle)).normalized(),
		(normalized_dir * -cos(arrow_angle) - right * sin(arrow_angle)).normalized(),
		(normalized_dir * -cos(arrow_angle) + up * sin(arrow_angle)).normalized(),
		(normalized_dir * -cos(arrow_angle) - up * sin(arrow_angle)).normalized()
	]
	
	for dir in arrow_directions:
		var arrow_line = BoxMesh.new()
		arrow_line.size = Vector3(LINE_THICKNESS * 0.8, LINE_THICKNESS * 0.8, arrow_size)
		
		var arrow_instance = MeshInstance3D.new()
		arrow_instance.mesh = arrow_line
		arrow_instance.material_override = material
		arrow_parent.add_child(arrow_instance)
		
		# Position the arrow line
		arrow_instance.position = end_point + dir * (arrow_size * 0.5)
		
		# Calculate and apply rotation for arrow head parts
		var arrow_basis: Basis
		if abs(dir.dot(Vector3.UP)) > 0.99:
			# Handle near-vertical arrow head parts
			if dir.dot(Vector3.UP) > 0:
				arrow_basis = Basis(Vector3.FORWARD, Vector3.LEFT, Vector3.UP)
			else:
				arrow_basis = Basis(Vector3.FORWARD, Vector3.RIGHT, Vector3.DOWN)
		else:
			# For all other cases
			var arrow_right = Vector3.UP.cross(dir).normalized()
			var arrow_up = dir.cross(arrow_right).normalized()
			arrow_basis = Basis(arrow_right, arrow_up, dir)
		
		arrow_instance.transform.basis = arrow_basis

	# Create a Timer node
	var timer = Timer.new()
	timer.set_wait_time(5.0)  # Set the timer for 6 seconds
	timer.set_one_shot(true)  # Make it a one-shot timer
	timer.connect("timeout", Callable(self, "_on_arrow_visualization_timer_timeout").bind(arrow_parent))
	
	# Add the timer to the sphere
	arrow_parent.add_child(timer)
	
	# Start the timer
	timer.start()
	
func _on_arrow_visualization_timer_timeout(parent) -> void:
	for child in parent.get_children():
		child.queue_free()
