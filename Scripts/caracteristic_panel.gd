extends Panel

var is_open = false
@onready var strengthDisplayed = $SkillList/Strength
@onready var staminaDisplayed = $SkillList/Stamina
@onready var charismaDisplayed = $SkillList/Charisma
@onready var agilityDisplayed = $SkillList/Agility
@onready var statsPointsDisplayed = $SkillList/StatsPoints
@onready var staminabar = $"../StaminaBar"
@onready var strength = $"../../../Player".strength
@onready var stamina = $"../../../Player".stamina
@onready var charisma = $"../../../Player".charisma
@onready var agility = $"../../../Player".agility
@onready var locked = $"../../../Player".locked


func _ready():
	close_panel()
	strengthDisplayed.text = str(strength)
	staminaDisplayed.text = str(stamina)
	charismaDisplayed.text = str(charisma)
	agilityDisplayed.text = str(agility)





func _input(_event: InputEvent):
	if Input.is_action_just_pressed("openingtab"):
		if is_open:
			close_panel()
			#Global.resume()
			$AnimationPlayer.play_backwards("blur")
			locked = false
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else: 
			open_panel()
			#Global.pause()
			$AnimationPlayer.play("blur")
			locked = true
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func open_panel():
	self.visible = true	
	is_open = true
	
func close_panel():
	self.visible = false
	is_open = false

#func pause the game if panel open
