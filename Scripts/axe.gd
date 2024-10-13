extends Node3D

@onready var animation_player = $"../../../../../AnimationPlayer"
@onready var raycasts = $Raycasts

var is_swinging := false

func _ready() -> void:
	disable_all_raycasts()

func _process(_delta: float) -> void:
	if is_swinging:
		collision_all_raycasts_on_tree()

func _on_animation_player_animation_started(anim_name: StringName) -> void:
	if anim_name == "metarig|Chop":
		start_swing()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "metarig|Chop":
		end_swing()

func start_swing() -> void:
	is_swinging = true
	enable_all_raycasts()

func end_swing() -> void:
	is_swinging = false
	disable_all_raycasts()

func enable_all_raycasts() -> void:
	for raycast in raycasts.get_children():
		if raycast is RayCast3D:
			raycast.enabled = true
			
func disable_all_raycasts() -> void:
	for raycast in raycasts.get_children():
		if raycast is RayCast3D:
			raycast.enabled = false

func collision_all_raycasts_on_tree() -> void:
	var collidedRaycasts = []
	for raycast in raycasts.get_children():
		if raycast is RayCast3D and raycast.is_colliding(): #and raycast.get_collider().name == "DeadTree":
			print(raycast.get_collider().name)
			collidedRaycasts.append(raycast)
			
	if collidedRaycasts.size() == 3:
		handle_tree_collision(collidedRaycasts)

func handle_tree_collision(treeCollidedRaycasts) -> void:
	print('madeittocollision')
	for raycast in treeCollidedRaycasts:
		if raycast.name == "RayCast3DTop":
			print("FoundTopBoy: " + raycast.name)
		elif raycast.name == "RayCast3DDepth":
			print("FoundDepthBoy: " + raycast.name)
		elif raycast.name == "RayCast3DBottom":
			print("FoundBottomBoy: " + raycast.name)
#	var collision_point = raycast.get_collision_point()
#	
#	collision_point = to_global(collision_point)
#	print("Axe hit the %s at global position: %s" % [collider.name, collision_point])
#	collision_points.append(collision_point)
#	visualize_collision_point(collision_point)  # Add this line for debug visualization

func visualize_collision_point(collisionPos: Vector3) -> void:
	var sphere = CSGSphere3D.new()
	sphere.radius = 0.05
	sphere.global_position = position
	get_tree().root.add_child(sphere)

func create_cpuparticles_3d()->void:
	pass
