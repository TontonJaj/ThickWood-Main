extends Panel

var is_open = false

func _ready():
	close_panel() 

func _input(_event: InputEvent):
	if Input.is_action_pressed("openingtab"):
		if is_open:
			close_panel()
		else: 
			open_panel()

func open_panel():
	self.visible = true	
	is_open = true
	
func close_panel():
	self.visible = false
	is_open = false

#func pause the game if panel open
