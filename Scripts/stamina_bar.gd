extends Panel

@onready var player = $"../../../Player"

func _ready():
	pass
# Called when the node enters the scene tree for the first time.

func update_stamina_bar():	
	$ProgressBar.value = Global.stamina
		

func timer_control():
	if Global.picked == true:
		$ProgressBar/StaminaRegen.stop()
		$ProgressBar/StaminaDegen.start()
	elif Global.picked == false:
		$ProgressBar/StaminaDegen.stop()
		$ProgressBar/StaminaRegen.start()

func _on_stamina_regen_timeout() :
	if Global.stamina < 99.7: 
		Global.stamina += 0.3 #one day, 4 will bee(Bzz, bzzzz) the stamina_regen_stat of the player
		update_stamina_bar()
#		if Global.stamina > 100: #Thats very cursed. 
#			Global.stamina = 100 #you can't just go from 101 to 100 every tick. Inappropriate.
#	if Global.stamina <= 0: #Even worse, it shouldn't be needed ever
#		Global.stamina = 0 #Waste of cpu and weird calculations when timing off
# I'm wtfing it all
		

func _on_stamina_degen_timeout() -> void:
	if Global.stamina > 0.5: 
		Global.stamina -= 0.5
		update_stamina_bar()
	else:
		player.drop_object()
