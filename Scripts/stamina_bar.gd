extends Panel

@onready var player = $"../../../Player"
@onready var staminaRegenStat = player.staminaRegenStat
@onready var staminaFull = player.staminaFull
@onready var staminaDegenStat = player.staminaDegenStat
@onready var staminaValue = player.staminaValue
@onready var picked = player.picked
@onready var is_sprinting = player.is_sprinting
@onready var is_chopping = player.is_chopping

func _ready():
	pass
# Called when the node enters the scene tree for the first time.

func update_stamina_bar():	
	print("imgay")
	$ProgressBar.value = staminaValue
		

func timer_control():
	if picked == true or is_sprinting == true or is_chopping == true:  #if doing difficult activities
		$ProgressBar/StaminaRegen.stop()
		$ProgressBar/StaminaDegen.start()
	elif picked == false:
		$ProgressBar/StaminaDegen.stop()
		$ProgressBar/StaminaRegen.start()

func _on_stamina_regen_timeout() :
	if staminaValue < (100-staminaRegenStat): 
		staminaValue += staminaRegenStat #one day, 4 will bee(Bzz, bzzzz) the stamina_regen_stat of the player
		update_stamina_bar()
	elif staminaValue == 100:
		staminaFull = true
		$ProgressBar/StaminaRegen.stop()
#		if Global.stamina > 100: #Thats very cursed. 
#			Global.stamina = 100 #you can't just go from 101 to 100 every tick. Inappropriate.
#	if Global.stamina <= 0: #Even worse, it shouldn't be needed ever
#		Global.stamina = 0 #Waste of cpu and weird calculations when timing off
# I'm wtfing it all
		
func _on_stamina_degen_timeout() -> void:
	if staminaValue > staminaDegenStat: 
		staminaValue -= staminaDegenStat
		update_stamina_bar()
	else:
		player.drop_object()
