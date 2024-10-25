extends MeshInstance3D

@onready var animation_player = $AnimationPlayer
@onready var interaction = $"../../../Player".interaction

# Called when the node enters the scene tree for the first time.
var is_pressed = false

func _process(_delta):
	if interaction.is_colliding() and Input.is_action_just_pressed("pick_up"): 
		press_button()


func press_button():
	if not is_pressed:
		is_pressed = true
		animation_player.play("Color change")
		await get_tree().create_timer(2.0).timeout
		animation_player.play_backwards("Color change")
		is_pressed = false
