extends MeshInstance3D

@onready var audio_player = $AudioStreamPlayer3D
var max_distance: float = 10.0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	audio_player.play() #Startplaying the sound

# Called every frame. 'delta' is the elapsed time since the previous frame.
