extends RigidBody3D

#Value per mass for the tree
@export var value_per_mass: float = 0.02
	
func _ready():
	var mass = get_mass() #get the current mass of the rigid body 3D
	var total_value = mass * value_per_mass
	print("Total value: ", total_value)
