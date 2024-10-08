extends RigidBody3D


func _input(event):
	var tree = $"."
	tree.add_to_group("trees")
