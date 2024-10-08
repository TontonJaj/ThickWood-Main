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
	var player = $Player
	var collider = $AdventurerGuildCounter/MeshInstance3D/SellButton/CollisionShape3D/SellZone
	var collided_item = collider.get_collider()
	if collided_item != null and collided_item is RigidBody3D:
		if collided_item.is_in_group("trees"):
			picked = false
			collided_item.queue_free()
	else:
		print("is not a tree")
