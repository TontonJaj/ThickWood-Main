extends Panel

@onready var player = $"../../../Player"

func _ready():
	pass
# Called when the node enters the scene tree for the first time.

func update_stamina_bar():	
	$ProgressBar.value = Global.staminaValue
		

func timer_control():
	if Global.picked == true or Global.is_sprinting == true or Global.is_chopping == true:  #if doing difficult activities
		$ProgressBar/StaminaRegen.stop()
		$ProgressBar/StaminaDegen.start()
	elif Global.picked == false:
		$ProgressBar/StaminaDegen.stop()
		$ProgressBar/StaminaRegen.start()

func _on_stamina_regen_timeout() :
	if Global.staminaValue < (100-Global.staminaRegenStat): 
		Global.staminaValue += Global.staminaRegenStat #one day, 4 will bee(Bzz, bzzzz) the stamina_regen_stat of the player
		update_stamina_bar()
	elif Global.staminaValue == 100:
		Global.staminaFull = true
		$ProgressBar/StaminaRegen.stop()
#		if Global.stamina > 100: #Thats very cursed. 
#			Global.stamina = 100 #you can't just go from 101 to 100 every tick. Inappropriate.
#	if Global.stamina <= 0: #Even worse, it shouldn't be needed ever
#		Global.stamina = 0 #Waste of cpu and weird calculations when timing off
# I'm wtfing it all
		
func _on_stamina_degen_timeout() -> void:
	if Global.staminaValue > Global.staminaDegenStat: 
		Global.staminaValue -= Global.staminaDegenStat
		update_stamina_bar()
	else:
		player.drop_object()
