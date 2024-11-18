extends Node

@onready var test_boxes = $"../TestBoxes"
@onready var player = $"../Player"

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
		
		var tree_name = body.name
		var calculated_value = test_boxes.get_tree_value(tree_name)
		print("selling zone want to give :", calculated_value)
		$"../GUI/PlayerInfo/UiBoardLargeParchment/Wallet".update_money(calculated_value)
		player.picked_object = null
		body.queue_free()
		$SellButton/Queching.playing = true

		if $"../Player".picked == true: #ensure that staminadegen only - if player still was picking when selled 
			$"../Player".staminaDegenStat -= $"../Player".holdDegenValue
			$"../Player".picked = false
			$"../GUI/PlayerInfo/StaminaBar".timer_control() # to fix not regening the stam when selling the object witout droping it
		else:
			$"../GUI/PlayerInfo/StaminaBar".timer_control()


		
