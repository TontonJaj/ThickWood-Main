extends Node

func handleChop(chopDict: Dictionary) -> void:
	#Can only dynamically modify arrayMeshes in GDScript
	#Right now I'm deleting (QUEUE_FREE) but I should keep it and refresh its' mesh
	var arrayMeshAndTransform = get_array_mesh_and_transform(chopDict.collider) #this is queue_freeing() don't forget to update instead in future
	if arrayMeshAndTransform.array_mesh == null or arrayMeshAndTransform.transform == null:
		return
	var treeArrayMesh = arrayMeshAndTransform.array_mesh
	var originalTreeTransform = arrayMeshAndTransform.transform
	
	treeArrayMesh = addVerticesFromCollisions(originalTreeTransform, treeArrayMesh, chopDict)
	
	
	
	visualize_collision_point(chopDict.top, Color.WEB_PURPLE)
	visualize_collision_point(chopDict.depth, Color.PALE_VIOLET_RED)
	visualize_collision_point(chopDict.bottom, Color.LIGHT_PINK)
	#treeArrayMesh = addVerticesToCollisions(treeArrayMesh, chopDict)
	add_skeleton_to_scene(originalTreeTransform, treeArrayMesh)
	add_transparent_to_scene(originalTreeTransform, treeArrayMesh)
	
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
	print(str(treeArrayMesh))
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
	material.albedo_color = Color.BLACK
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
	timer.set_wait_time(4.0)  # Set the timer for 6 seconds
	timer.set_one_shot(true)  # Make it a one-shot timer
	timer.connect("timeout", Callable(self, "_on_visualization_timer_timeout").bind(sphere))
	
	# Add the timer to the sphere
	sphere.add_child(timer)
	
	# Start the timer
	timer.start()

func _on_visualization_timer_timeout(sphere: CSGSphere3D) -> void:
	if is_instance_valid(sphere):
		sphere.queue_free()
