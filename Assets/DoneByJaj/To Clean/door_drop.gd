extends MeshInstance3D

@onready var animation_player = $"../AnimationPlayer"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func disappear():
	var collision_shape3D = $"../CollisionShape3D"
	$"../CollisionShape3D".queue_free()
	
	collision_shape3D
	
