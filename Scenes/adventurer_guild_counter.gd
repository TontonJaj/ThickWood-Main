extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

#this whole function need revisiting. having so many direct references dependecies is wrong and calling timer_control() twice is wak.
	
func _on_sell_button_body_entered(body: Node3D) -> void:
	if body.is_in_group("trees") and body is RigidBody3D:
		#trying to take size of the wood and * it by value of wood type
		var mass = body.mass #get the mass from the RB3D
		var value_per_mass = body.get_parent().value_per_mass #access the custom property
		var total_value = mass * value_per_mass
		
		$"../GUI/PlayerInfo/Wallet".update_money(total_value)
		body.queue_free()
		$"../GUI/PlayerInfo/StaminaBar".timer_control() # to fix not regening the stam when selling the object witout droping it

		$"../Player".picked = false

		$SellButton/Queching.playing = true
		$"../Player".staminaDegenStat -= $"../Player".holdDegenValue
		$"../GUI/PlayerInfo/StaminaBar".timer_control()

		
	else:
		print("is missing a condition (ingrouptree/rigidbody3d)")
