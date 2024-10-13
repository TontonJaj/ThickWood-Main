extends RigidBody3D

#Value per mass for the tree
@export var value_per_mass: float = 0.02
	
func _ready():
	pass
#	var mass = get_mass() #get the current mass of the rigid body 3D
#	var _total_value = mass * value_per_mass
#mad	print("Total value: ", total_value)

#something is very wrong with this GDScript. Feels cursed AF. I commented it all out and game still running with less errors!!!
