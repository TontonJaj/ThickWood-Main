extends StaticBody3D

#speed of the conveyor belt
var speed: float = 0.6
var movable_bodies = []




func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("movable"): #Ensure the object can be moved
		print("dds")
		movable_bodies.append(body)


func _on_area_3d_body_exited(body: Node3D) -> void:
	movable_bodies.erase(body)
	
	
	#Called every physics frame
func _physics_process(_delta): 
	#Get all bodies overlapping the conveyor belt
	for body in movable_bodies:#Apply a linear velocity to the body in the convetor belt direction
		print(body, "sds")
		body.linear_velocity.x = -speed #Change the axis based on belt orientation
	
	
