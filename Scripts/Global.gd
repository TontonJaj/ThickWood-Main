extends Node

var XP = 0

#Update money
func update_money(revenue):
	#Money declaraction
	var cp = $Wallet.CP
	var sp = $Wallet.SP
	var gp = $Wallet.GP
	var pp = $Wallet.PP
			
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
	
	$Wallet.CP = cp
	$Wallet.SP = sp
	$Wallet.GP = gp
	$Wallet.PP = pp

	print("cp",$Wallet.CP,"sp",$Wallet.SP ,"gp",$Wallet.GP, "pp",pp)
			
	
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
		update_money(bodyvalue)
		body.queue_free()
	else:
		print("is missing a condition (ingrouptree/rigidbody3d)")
