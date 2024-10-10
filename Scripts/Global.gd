extends Node

var XP = 0

#player caracteristic
@export
var strength : int = 10
var stamina : float = 80

#Update money
func update_money(revenue):
	#Money declaraction
	var cp = $GUI/PlayerInfo/Wallet.CP
	var sp = $GUI/PlayerInfo/Wallet.SP
	var gp = $GUI/PlayerInfo/Wallet.GP
	var pp = $GUI/PlayerInfo/Wallet.PP
			
	cp += revenue
	if cp > 99:
		sp += int(cp/100) 
		cp = fmod(cp,100) 
	if sp > 99:
		gp += int(sp/100)
		sp = fmod(sp,100)
	if gp > 99:
		pp += int(gp/100)
		gp = fmod(gp,100)
	
	$GUI/PlayerInfo/Wallet.CP = cp
	$GUI/PlayerInfo/Wallet.SP = sp
	$GUI/PlayerInfo/Wallet.GP = gp
	$GUI/PlayerInfo/Wallet.PP = pp
	$GUI/PlayerInfo/Wallet.update_money_wallet()
	

	print("cp",$GUI/PlayerInfo/Wallet.CP,"sp",$GUI/PlayerInfo/Wallet.SP ,"gp",$GUI/PlayerInfo/Wallet.GP, "pp",pp)
			
	
#@export what ? 
var picked = false #this is global and easy to hack and bug. also see comment @player.gd
		

func _ready()-> void:
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
		var mass = body.mass #get the mass from the RB3D
		var value_per_mass = body.value_per_mass #access the custom property
		var total_value = mass * value_per_mass
		print("Sold the tree total value: ", total_value)
		update_money(total_value)
		body.queue_free()
	else:
		print("is missing a condition (ingrouptree/rigidbody3d)")
