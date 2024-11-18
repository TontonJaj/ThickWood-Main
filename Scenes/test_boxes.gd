extends Node


var calculated_value : Dictionary = {}
var tree_tier_1_multiplicator : float = 4.0

	

# Called when the node enters the scene tree for the first time.
func _ready():
	for child in get_children(): #iterate through all children
		if child is RigidBody3D and child.is_in_group("trees"):
			calculate_value(child) #pass the child to the function

# Called every frame. 'delta' is the elapsed time since the previous frame.

#function to calculate value for each tree
func calculate_value(child: RigidBody3D):
	var value
	if child.is_in_group("deadwood"):
		#calculate the value_per_mass
		var mass = child.mass
		if child.is_in_group("processed"):
			value = 0.04 * mass * tree_tier_1_multiplicator
			#print("is in group proccessed. value is :", value)
		else:
			value = 0.01 * mass * tree_tier_1_multiplicator
			#print("is not in group proccessed. value is :", value)


		#store in the dictionnary using the child's name or path as a key
	calculated_value[child.name] = value
	#print("Wood: ", child.name, " Value per Mass: ", calculated_value)
	
	# Function to recalculate values for all trees
func recalculate_values():
	calculated_value.clear()  # Clear existing values
	for child in get_children():
		if child is RigidBody3D and child.is_in_group("trees"):
			calculate_value(child)
	
func get_tree_value(tree_name: String) -> float:
	return calculated_value.get(tree_name, 0.0) #return 0 if not found
	
func _process(_delta: float) -> void:
	pass
