extends Panel

@onready var player = $"../../../Player"


func _ready():
	pass
# Called when the node enters the scene tree for the first time.


func update_stamina_bar():	
	$ProgressBar.value = player.staminaValue

		

func timer_control():
	var is_chopping = player.is_chopping
	var picked = player.picked
	var is_sprinting = player.is_sprinting
	var is_jumping = player.is_jumping

	if picked or is_sprinting or is_chopping or is_jumping:  #if doing difficult activities
		$ProgressBar/StaminaRegen.stop()
		$ProgressBar/StaminaDegen.start()
	elif not picked:
		$ProgressBar/StaminaDegen.stop()
		await get_tree().create_timer(1.0).timeout
		$ProgressBar/StaminaRegen.start()

func _on_stamina_regen_timeout() :
	if player.staminaValue < (100-player.staminaRegenStat): 
		player.staminaValue += player.staminaRegenStat #one day, 4 will bee(Bzz, bzzzz) the stamina_regen_stat of the player
		update_stamina_bar()
	elif player.staminaValue >= 100:
		player.staminaFull = true
		$ProgressBar/StaminaRegen.stop()
#		if Global.stamina > 100: #Thats very cursed. 
#			Global.stamina = 100 #you can't just go from 101 to 100 every tick. Inappropriate.
#	if Global.stamina <= 0: #Even worse, it shouldn't be needed ever
#		Global.stamina = 0 #Waste of cpu and weird calculations when timing off
# I'm wtfing it all
		
func _on_stamina_degen_timeout() :
	if player.staminaValue > player.staminaDegenStat: 
		player.staminaValue -= player.staminaDegenStat
		update_stamina_bar()
		print(player.staminaValue)
	else:
		player.drop_object()
