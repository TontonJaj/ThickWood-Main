extends Panel

var is_open = false
@onready var player = $"../../../Player"
@onready var strengthDisplayed = $SkillList/Strength
@onready var staminaDisplayed = $SkillList/Stamina
@onready var charismaDisplayed = $SkillList/Charisma
@onready var agilityDisplayed = $SkillList/Agility
@onready var statsPointsDisplayed = $SkillList/StatsPoints
@onready var staminabar = $"../StaminaBar"


func _ready():
	close_panel()
	update_caracteristics_displayed()

func update_caracteristics_displayed():
	strengthDisplayed.text = str(player.strength)
	staminaDisplayed.text = str(player.stamina)
	charismaDisplayed.text = str(player.charisma)
	agilityDisplayed.text = str(player.agility)
	statsPointsDisplayed.text = str(player.statspoints)





func _input(_event: InputEvent):
	if Input.is_action_just_pressed("openingtab"):
		if is_open:
			close_panel()
			#Global.resume()
			$AnimationPlayer.play_backwards("blur")
			player.locked = false
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else: 
			open_panel()
			#Global.pause()
			$AnimationPlayer.play("blur")
			player.locked = true
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func open_panel():
	self.visible = true	
	is_open = true
	player.playerFixed = true
	
func close_panel():
	self.visible = false
	is_open = false
	player.playerFixed = false

#func pause the game if panel open


func _on_up_button_strength_button_up():
	if player.statspoints >= 1:
		player.strength += 1
		player.statspoints -= 1
		#print(player.statspoints)
		#print(player.strength)
		update_caracteristics_displayed()


func _on_up_button_stamina_button_up():
	if player.statspoints >= 1:
			player.stamina += 1
			player.statspoints -= 1
			#print(player.statspoints)
			#print(player.stamina)
			update_caracteristics_displayed()
			staminabar.update_stamina_max_value()

func _on_up_button_charisma_button_up():
	if player.statspoints >= 1:
		player.charisma += 1
		player.statspoints -= 1
		#print(player.statspoints)
		#print(player.charisma)
		update_caracteristics_displayed()

func _on_up_button_agility_button_up():
	if player.statspoints >= 1:
		player.agility += 1
		player.statspoints -= 1
		#print(player.statspoints)
		#print(player.agility)
		update_caracteristics_displayed()
