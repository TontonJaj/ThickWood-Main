extends Node3D

@onready var animation_player = $"../../../../../AnimationPlayer"
@onready var raycasts = $Raycasts

var is_swinging = false
var collidedTreeDictionnary = {
	"collider": null,
	"bottom": null,
	"depth": null,
	"top": null
}
var choppedAlready = false

func clearcollidedTreeDictionnary() -> void:
	collidedTreeDictionnary.collider = null
	collidedTreeDictionnary.top = null
	collidedTreeDictionnary.depth = null
	collidedTreeDictionnary.bottom = null

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
	clearcollidedTreeDictionnary()
	choppedAlready = false

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
	if !choppedAlready and collidedTreeDictionnary.top and collidedTreeDictionnary.depth and collidedTreeDictionnary.bottom:
		handle_tree_collision()
		return
	for raycast in raycasts.get_children():
		if raycast is RayCast3D and raycast.is_colliding() and raycast.get_collider().name == "DeadTreeStatic": #need another condition for multiple trees
			if !collidedTreeDictionnary.collider:
				collidedTreeDictionnary.collider = raycast.get_collider()
			if raycast.name == "RayCast3DTop" and !collidedTreeDictionnary.top:
				collidedTreeDictionnary.top = raycast.get_collision_point()
			if raycast.name == "RayCast3DDepth" and !collidedTreeDictionnary.depth:
				collidedTreeDictionnary.depth = raycast.get_collision_point()
			if raycast.name == "RayCast3DBottom" and !collidedTreeDictionnary.bottom:
				collidedTreeDictionnary.bottom = raycast.get_collision_point()

func handle_tree_collision() -> void:
	choppedAlready = true
	print('madeittocollision')
	#if collidedTreeDictionnary.top:
		#visualize_collision_point(collidedTreeDictionnary.top)
	#if collidedTreeDictionnary.depth:
		#visualize_collision_point(collidedTreeDictionnary.depth)
	#if collidedTreeDictionnary.bottom:
		#visualize_collision_point(collidedTreeDictionnary.bottom)
	collidedTreeDictionnary.collider.find_parent("Trees").handleChop(collidedTreeDictionnary)
	

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

func create_cpuparticles_3d()->void:
	pass
