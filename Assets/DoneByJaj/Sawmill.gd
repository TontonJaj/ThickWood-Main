extends MeshInstance3D

@onready var audio_player = $AudioStreamPlayer3D
var max_distance: float = 10.0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	audio_player.play() #Startplaying the sound

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var player = $"../Player"
	if player:
		var distance = global_transform.origin.distance_to(player.global_transform.origin)
		var volume = clamp(distance / max_distance, 0.0, 1.0) # Calculate volume based on distance
		audio_player.volume_db = linear_to_db(volume) #set volume in db 
