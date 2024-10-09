extends Node3D


func _process(_delta: float) -> void:
	# Check if the 'End' key (mapped to 'ui_end') is pressed
	if Input.is_action_just_pressed("engine_end"):
		get_tree().quit()  # Closes the game
