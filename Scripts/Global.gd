extends Node

# already declared in PlayerStats.gd ?
#var CP = 0
#var SP = 0
#var GP = 0
#var XP = 0

#@export what ? 
var picked = false #this is global and easy to hack and bug. also see comment @player.gd
	#log value # Replace with function body. tehfuck
		

func _ready():
	# Initialize your game here
	pass

func _input(event):
	# Check for 'end' input every frame
	# Should remove "escape" assigned to end in controls input when trying to do a menu
	if event.is_action_pressed("end"):
		get_tree().quit()

#selling wood if wood is wood ~ this should have it's own script (eg : 'sellbutton.gd')
func _on_sell_button_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	print(str(body) + "has entered the selling button")
	if body.is_in_group("trees") and body is RigidBody3D:
		Global.picked = false
		#trying to take size of the wood and * it by value of wood type
		var bodyvalue = body.mass
		print(bodyvalue)
		body.queue_free()
	else:
		print("is missing a condition (ingrouptree/rigidbody3d)")
