extends Panel


func _ready():
	update_stamina_bar()
# Called when the node enters the scene tree for the first time.

func update_stamina_bar():	
	$ProgressBar.value = Global.stamina
		

func timer_control():
	print("timer onoff")
	if Global.picked == true:
		$ProgressBar/StaminaRegen.stop()
		print("timer off")
	else:
		$ProgressBar/StaminaRegen.start()
	


func _on_stamina_regen_timeout() :
	if Global.stamina < 100: 
		Global.stamina = Global.stamina + 0.3 #one day, 4 will bee the stamina_regen_stat of the player
		if Global.stamina > 100:
			Global.stamina = 100
	if Global.stamina <= 0:
		Global.stamina = 0
	update_stamina_bar()
		
