extends Node

var XP = 0

#player caracteristic
#@export STOPTHATSHIT CA MA ENCORE FAIT PERDRE 2H!!!! wtf man..je me repend au sein de lesprit de la grande sainteté ammen
var strength : int = 10
var stamina : float = 100
#var speed : int = 10 for animation speed ? faster cut cut and also better penetration if we create a damage dealt per hit variable or something
var staminaRegenStat = 0.3
var staminaDegenStat = 0.1
var staminaFull : bool = true

@onready var staminaBar = $GUI/PlayerInfo/StaminaBar


var picked : bool = false


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
 #this is global and easy to hack and bug. also see comment @player.gd
		

func list_node_and_children(node: Node, indent: int = 0, is_last: bool = true):
	# Create the indentation string
	var indentation = ""
	for i in range(indent - 1):
		indentation += "│  " if i < indent - 1 else "   "
	
	if indent > 0:
		indentation += "└─ " if is_last else "├─ "
	
	# Print the current node's name with indentation for hierarchy
	print(indentation + node.name)
	
	# Iterate over each child and recursively call the function
	var children = node.get_children()
	for i in range(children.size()):
		var child = children[i]
		list_node_and_children(child, indent + 1, i == children.size() - 1)

func _ready()-> void:
	pass
	

func _input(event):
	# Check for 'end' input every frame
	# Should remove "escape" assigned to end in controls input when trying to do a menu
	if event.is_action_pressed("end"):
		get_tree().quit()

#selling wood if wood is wood ~ this should have it's own script (eg : 'sellbutton.gd')
func _on_sell_button_body_shape_entered(_body_rid: RID, body: Node3D, _body_shape_index: int, _local_shape_index: int) -> void:
	print(str(body) + "has entered the selling button")
	if body.is_in_group("trees") and body is RigidBody3D:
		Global.picked = false
		staminaBar.timer_control() # to fix not regening the stam when selling the object witout droping it
		
		#trying to take size of the wood and * it by value of wood type
		var mass = body.mass #get the mass from the RB3D
		var value_per_mass = body.value_per_mass #access the custom property
		var total_value = mass * value_per_mass
		print("Sold the tree total value: ", total_value)
		update_money(total_value)
		body.queue_free()
		$AdventurerGuildCounter/SellButton/Queching.playing = true
		
	else:
		print("is missing a condition (ingrouptree/rigidbody3d)")
