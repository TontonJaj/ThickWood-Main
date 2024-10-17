extends Node

func visualize_collision_point(collisionPos: Vector3) -> void:
	if not is_inside_tree():
		print("Warning: Attempting to visualize collision point while not in scene tree.")
		return

	var sphere = CSGSphere3D.new()
	sphere.name = "Node_" + str(Time.get_ticks_msec())
	sphere.radius = 0.015

	# Create a new material
	var material = StandardMaterial3D.new()
	material.albedo_color = Color.WEB_PURPLE
	
	# Assign the material to the sphere
	sphere.material = material

	# Add the sphere to the scene first
	get_tree().current_scene.add_child(sphere)

	# Then set its position
	sphere.global_transform.origin = collisionPos

func handleChop(chopDict: Dictionary) -> void:
	#Can only dynamically modify arrayMeshes in GDScript
	#need a function out of handleChop to get the arrayMesh properly and the reference to the meshInstance
	#Right now I'm deleting (QUEUE_FREE) but I should keep it and refresh its' mesh
	var treeArrayMesh = null
	var originalTreeTransform = null
	if chopDict.collider is ArrayMesh:
		treeArrayMesh = chopDict.collider
		originalTreeTransform = treeArrayMesh.global_transform
		#I'm repeating myself twice here, WRONG!
	elif chopDict.collider is MeshInstance3D:
		originalTreeTransform = chopDict.collider.global_transform
		treeArrayMesh = convert_instance_to_array_mesh(chopDict.collider)
		chopDict.collider.queue_free()
	else:
		var parent_mesh_instance = find_meshinstance3d_parent(chopDict.collider)
		if parent_mesh_instance:
			originalTreeTransform = parent_mesh_instance.global_transform
			treeArrayMesh = convert_instance_to_array_mesh(parent_mesh_instance)
			parent_mesh_instance.queue_free()
	
	if not (treeArrayMesh is ArrayMesh):
		print('handleChop failing on type')
		return
	
	visualize_collision_point(chopDict.top)
	visualize_collision_point(chopDict.depth)
	visualize_collision_point(chopDict.bottom)
	#treeArrayMesh = addVerticesToCollisions(treeArrayMesh, chopDict)
	add_skeleton_to_scene(originalTreeTransform, treeArrayMesh)
	add_transparent_to_scene(originalTreeTransform, treeArrayMesh)
	
func addVerticesToCollisions(treeArrayMesh, chopDict):
	var st = SurfaceTool.new()
	st.create_from(treeArrayMesh, 0)  # Assuming the tree is on the first surface
	#I really need to make that func work
	
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
