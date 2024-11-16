extends MeshInstance3D

@onready var animation_player = $"../AnimationPlayer"
var is_closed = false
@onready var door_drop = $"../DoorDrop/Hinge/StaticBody3D/CollisionShape3D"
# Called when the node enters the scene tree for the first time.



func close_the_security_door():
	animation_player.play("Securitygaragedoorclose")
	await animation_player.animation_finished
	is_closed = true
	animation_player.play("DroptheWood")
	$SawingBlades.play()
	await get_tree().create_timer(2.0).timeout
	animation_player.play_backwards("DroptheWood")
	#refresh_to_last_key_position()
	await animation_player.animation_finished
	animation_player.play_backwards("Securitygaragedoorclose")
	await animation_player.animation_finished
	animation_player.play_backwards("Color change")
	$"../StartButton/StartButtonBase/RedButton".is_pressed = false
	
	
