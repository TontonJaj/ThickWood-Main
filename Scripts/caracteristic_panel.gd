extends Panel

var is_open = false
@onready var strengthDisplayed = $Panel2/Strength
@onready var staminaDisplayed = $Panel2/Stamina
@onready var charismaDisplayed = $Panel2/Charisma
@onready var agilityDisplayed = $Panel2/Agility
@onready var statsPointsDisplayed = $Panel2/StatsPoints
@onready var staminabar = $"../StaminaBar"

func _ready():
	close_panel()
	strengthDisplayed.text = str(Global.strength)
	staminaDisplayed.text = str(Global.strength)
	charismaDisplayed.text = str(Global.strength)
	agilityDisplayed.text = str(Global.strength)





func _input(_event: InputEvent):
	if Input.is_action_just_pressed("openingtab"):
		if is_open:
			close_panel()
			Global.resume()
			$AnimationPlayer.play_backwards("blur")
			Global.locked = false
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else: 
			open_panel()
			Global.pause()
			$AnimationPlayer.play("blur")
			Global.locked = true
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func open_panel():
	self.visible = true	
	is_open = true
	
func close_panel():
	self.visible = false
	is_open = false

#func pause the game if panel open
