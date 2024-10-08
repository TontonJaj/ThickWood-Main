extends Node3D

@onready var animation_player = $"../../../../../AnimationPlayer"
@onready var raycast = $RayCast3D
@onready var console = get_node("/root/Main/Console")

const CUTTING_PLANE_SIZE = Vector3(10, 0.1, 10)  # Thickness added as Y

var collision_points: Array[Vector3] = []
var is_swinging := false

func _ready() -> void:
	raycast.enabled = false

func _process(_delta: float) -> void:
	if is_swinging and raycast.is_colliding():
		handle_collision()

func handle_collision() -> void:
	var collision_point = raycast.get_collision_point()
	var collider = raycast.get_collider()
	
	if collider.name == "DeadTree":
		collision_point = to_global(collision_point)
		console.log_message("Axe hit the %s at global position: %s" % [collider.name, collision_point])
		collision_points.append(collision_point)
		visualize_collision_point(collision_point)  # Add this line for debug visualization

func visualize_collision_point(position: Vector3) -> void:
	var sphere = CSGSphere3D.new()
	sphere.radius = 0.05
	sphere.global_position = position
	get_tree().root.add_child(sphere)

func _on_animation_player_animation_started(anim_name: StringName) -> void:
	if anim_name == "metarig|Chop":
		start_swing()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "metarig|Chop":
		end_swing()

func start_swing() -> void:
	console.log_message("Axe swing started")
	is_swinging = true
	raycast.enabled = true
	collision_points.clear()

func end_swing() -> void:
	console.log_message("Axe swing finished")
	is_swinging = false
	raycast.enabled = false
	
	if collision_points.size() >= 2:
		create_cutting_plane()

func create_cutting_plane() -> void:
	var start_point = collision_points.front()
	var end_point = collision_points.back()
	var center = (start_point + end_point) / 2
	var cut_direction = (end_point - start_point).normalized()
	
	console.log_message("Creating cutting plane at global position %s with direction %s" % [center, cut_direction])
	
	var plane = CSGBox3D.new()
	plane.size = CUTTING_PLANE_SIZE
	
	var material = StandardMaterial3D.new()
	material.flags_transparent = true
	material.albedo_color = Color(1, 0, 0, 0.5)
	plane.material = material
	
	get_tree().root.add_child(plane)
	
	# Set position and orientation
	plane.global_position = center
	
	var up = Vector3.UP
	var right = cut_direction.cross(up).normalized()
	up = right.cross(cut_direction).normalized()
	
	plane.global_transform.basis = Basis(right, up, -cut_direction)
	
	console.log_message("Plane created at position: " + str(plane.global_position))
