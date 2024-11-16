extends MeshInstance3D

@onready var animation_player = $"../../../AnimationPlayer"
@onready var interaction = $"../../../../Player".interaction

# Called when the node enters the scene tree for the first time.
var is_pressed = false

func _ready() ->void:
	pass 
	
	
func _process(_delta):
	var object = interaction.get_collider()
	if object == $"../.." and Input.is_action_just_pressed("pick_up"):
		press_button() 




func press_button():
		if not is_pressed:
			is_pressed = true
			animation_player.play("Color change")
			await animation_player.animation_finished
			$"../../../SecurityGarageDoor".close_the_security_door()
		
		
