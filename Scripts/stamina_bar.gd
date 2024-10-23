extends Panel

@onready var player = $"../../../Player"
@onready var progressbar = $ProgressBar


func _ready():
	update_stamina_max_value()
# Called when the node enters the scene tree for the first time.

func update_stamina_max_value():
	progressbar.max_value = float(player.stamina * 10)
	timer_control()

func update_stamina_bar():	
	$ProgressBar.value = player.staminaValue

		

func timer_control():

	if player.picked or player.is_sprinting or player.is_chopping or player.is_jumping:  #if doing difficult activities
		$ProgressBar/StaminaRegen.stop()
		$ProgressBar/StaminaDegen.start()
	elif !player.picked:
		$ProgressBar/StaminaDegen.stop()
		await get_tree().create_timer(1.0).timeout
		if !player.picked:
			$ProgressBar/StaminaRegen.start()

func _on_stamina_regen_timeout() :
	if player.staminaValue < (progressbar.max_value-player.staminaRegenStat): 
		player.staminaValue += player.staminaRegenStat #one day, 4 will bee(Bzz, bzzzz) the stamina_regen_stat of the player
		update_stamina_bar()
	elif player.staminaValue >= progressbar.max_value:
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
	else:
		player.drop_object()
