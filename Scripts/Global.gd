extends Node



#player caracteristic
#@export STOPTHATSHIT CA MA ENCORE FAIT PERDRE 2H!!!! wtf man..je me repend au sein de lesprit de la grande sainteté ammen



func _ready() -> void:
	pass
			
	
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


	

func _input(event):
	# Check for 'end' input every frame
	# Should remove "escape" assigned to end in controls input when trying to do a menu
	if event.is_action_pressed("end"):
		get_tree().quit()

#selling wood if wood is wood ~ this should have it's own script (eg : 'sellbutton.gd')
	
		
func pause():
	get_tree().paused = true

func resume():
	get_tree().paused = false #Used for pausing and depausing when in the caraC MENU  rn but someday it will only be for pause menu
	
