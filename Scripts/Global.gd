extends Node

var CP = 0
var SP = 0
var GP = 0
var XP = 0

@export 
var picked = false
	#log value # Replace with function body.
		

#selling wood if wood is wood
func _on_sell_button_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	print("has entered")
	
	#trying to take size of the wood and * it by value of wood type
	var bodyvalue = body.get("MeshInstanc3D/Size")
	print(bodyvalue)
	
	if body.is_in_group("trees") and body is RigidBody3D:
		Global.picked = false
		var body_value = body
		body.queue_free()
			
	else:
		print("is missing a condition (ingrouptree/rigidbody3d)")
