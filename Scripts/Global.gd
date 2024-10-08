extends Node

var CP = 0
var SP = 0
var GP = 0
var XP = 0


	#log value # Replace with function body.
		
	




#selling wood if wood is wood
func _on_sell_button_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	var player = $Player
	var collider = $AdventurerGuildCounter/MeshInstance3D/SellButton/CollisionShape3D/SellZone
	var collided_item = collider.get_collider()
	collided_item != null
	if collided_item.is_in_group("trees"):
		collided_item.queue_free()
	else:
		print("is not a tree")
